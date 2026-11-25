//
//  Created by Kurlovich Vitali on 9/18/26.
//

import CoreImage
import Foundation

public nonisolated struct CubeLUTMeta: Hashable, Sendable {
    public let title: String
    public let description: String

    public init(title: String, description: String) {
        self.title = title
        self.description = description
    }
}

public nonisolated enum CubeLUTKind: Hashable, Sendable {
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

    // public let data: Data
    //
    //  public let values: [Float]

    public let payload: CubeLUTPayload
    private let dataTask: Task<Data, any Error> // data: Data

    public init(
        title: String = "",
        description: String = "",
        kind: Kind,
        dimension: Int,
        values: [Float],
        domainMin: SIMD3<Float>,
        domainMax: SIMD3<Float>
    ) {
        let meta = CubeLUTMeta(title: title, description: description)

        let payload = CubeLUTPayload(meta: meta, kind: kind, dimension: dimension, domainMin: domainMin, domainMax: domainMax)

        let data = values.withUnsafeBytes {
            Data($0)
        }

        self.init(payload: payload) {
            data
        }
    }

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

    init(_ url: URL) async throws(CubeLUTError) {
        self = try await parseCubeLUT(url.lines)
    }
}
