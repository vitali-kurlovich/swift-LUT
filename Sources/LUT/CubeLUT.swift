//
//  Created by Kurlovich Vitali on 9/18/26.
//

import Foundation

public nonisolated struct CubeLUTMeta: Hashable, Sendable {
    public let title: String
    public let description: String

    public init(title: String, description: String) {
        self.title = title
        self.description = description
    }
}

public nonisolated enum CubeLUTKind: Int, Hashable, Sendable, Codable {
    /// Per-channel curves (`LUT_1D_SIZE`); `data` holds `dimension` float RGB triplets.
    case oneDimensional
    /// Color cube (`LUT_3D_SIZE`); `data` holds `dimension³` float RGBA values, red varying fastest.
    case threeDimensional
}

public nonisolated struct CubeLUTPayload: Hashable, Sendable {
    public typealias Kind = CubeLUTKind
    public let meta: CubeLUTMeta

    public let kind: Kind
    public let dimension: Int
    public let domainMin: SIMD3<Float>
    public let domainMax: SIMD3<Float>

    public init(
        meta: CubeLUTMeta,
        kind: Kind,
        dimension: Int,
        domainMin: SIMD3<Float>,
        domainMax: SIMD3<Float>
    ) {
        self.meta = meta
        self.kind = kind
        self.dimension = dimension
        self.domainMin = domainMin
        self.domainMax = domainMax
    }
}

public nonisolated extension CubeLUT {
    var kind: Kind {
        payload.kind
    }

    var dimension: Int {
        payload.dimension
    }

    var domainMin: SIMD3<Float> {
        payload.domainMin
    }

    var domainMax: SIMD3<Float> {
        payload.domainMax
    }

    var meta: CubeLUTMeta {
        payload.meta
    }

    var title: String {
        meta.title
    }

    var description: String {
        meta.description
    }
}

public nonisolated struct CubeLUT: Hashable, Sendable {
    public typealias Kind = CubeLUTKind

    public let payload: CubeLUTPayload
    private let dataTask: Task<Data, any Error> // data: Data

    public init(
        payload: CubeLUTPayload,
        data: @escaping @Sendable () throws -> Data
    ) {
        self.payload = payload
        dataTask = Task {
            try data()
        }
    }
}

public nonisolated extension CubeLUT {
    func data() async throws -> Data {
        try await dataTask.value
    }
}

public extension CubeLUT {
    init(_ text: String) throws(CubeLUTError) {
        self = try parseCubeLUT(text)
    }

    init(_ data: Data) throws(CubeLUTError) {
        guard let text = String(data: data, encoding: .utf8) else {
            throw CubeLUTError.invalidFormat
        }
        try self.init(text)
    }
}

public extension CubeLUT {
    init(_ url: URL) throws(CubeLUTError) {
        if url.pathExtension.lowercased() == "cube" {
            try self.init(cubeURL: url)
        } else if url.pathExtension.lowercased() == "pcube" {
            try self.init(pCubeURL: url)
        } else {
            throw CubeLUTError.unknownFileFormat(url)
        }
    }
}

private extension CubeLUT {
    init(pCubeURL url: URL) throws(CubeLUTError) {
        do {
            let data = try Data(contentsOf: url)
            try self.init(bCubeData: data)
        } catch let error as CubeLUTError {
            throw error
        } catch {
            throw CubeLUTError.IOError(error)
        }
    }

    init(cubeURL url: URL) throws(CubeLUTError) {
        do {
            let lineReader = FileLineReader(url: url, chunkSize: 256)

            var parser = CubeLUTParser()

            try lineReader.readLines { line in
                try parser.nextLine(line)
                return parser.isPayloadReady == false
            }

            let payload = try parser.payload()

            self.init(payload: payload, data: {
                let lineReader = FileLineReader(url: url, chunkSize: 1 << 16)

                var parser = CubeLUTParser()

                try lineReader.readLines { line in
                    try parser.nextLine(line)
                    return true
                }

                return try parser.valuesData()
            })

        } catch let error as CubeLUTError {
            throw error
        } catch {
            throw CubeLUTError.invalidFormat
        }
    }
}
