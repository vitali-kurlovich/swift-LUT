//
//  CubeLUTConverter.swift
//  swift-LUT
//
//  Created by Kurlovich Vitali on 9/23/26.
//

import Compression
import Foundation
import SwiftProtobuf

public nonisolated struct CubeLUTConverter: Hashable, Sendable {
    public init() {}
}

public extension CubeLUTConverter {
    nonisolated func load(_ url: URL, using algorithm: Algorithm = .lzma) throws -> CubeLUT {
        try load(Data(contentsOf: url), using: algorithm)
    }

    nonisolated func save(cube: CubeLUT, to url: URL, using algorithm: Algorithm = .lzma) throws {
        let data = try save(cube: cube, using: algorithm)
        try data.write(to: url, options: .atomic)
    }
}

public extension CubeLUTConverter {
    nonisolated func load(_ data: Data, using algorithm: Algorithm = .lzma) throws -> CubeLUT {
        let decompressedData = try decompress(data, using: algorithm)

        let pcube = try PCubeLUT(serializedBytes: decompressedData)

        return CubeLUT(pcube)
    }

    nonisolated func save(cube: CubeLUT, using algorithm: Algorithm = .lzma) throws -> Data {
        let pCube = PCubeLUT(cube)
        let data = try pCube.serializedData()

        return try compress(data, using: algorithm)
    }
}

private extension CubeLUTConverter {
    nonisolated func decompress(_ data: Data, using algorithm: Algorithm = .lzma) throws -> Data {
        let compressedData = data
        var decompressedData = Data()
        let pageSize = 4 * 1024

        let outputFilter = try OutputFilter(.decompress,
                                            using: algorithm)
        { (
            data: Data?
        ) in
            if let data = data {
                decompressedData.append(data)
            }
        }

        var index = 0
        let bufferSize = compressedData.count

        while true {
            let rangeLength = min(pageSize, bufferSize - index)

            let subdata = compressedData.subdata(in: index ..< index + rangeLength)
            index += rangeLength
            try outputFilter.write(subdata)
            if rangeLength == 0 {
                break
            }
        }

        return decompressedData
    }

    nonisolated func compress(_ data: Data, using algorithm: Algorithm = .lzma) throws -> Data {
        let pageSize = 4 * 1024
        let sourceData = data
        var compressedData = Data()

        let outputFilter = try OutputFilter(.compress,
                                            using: algorithm)
        {
            (data: Data?) in
            if let data = data {
                compressedData.append(data)
            }
        }

        var index = 0
        let bufferSize = sourceData.count

        while true {
            let rangeLength = min(pageSize, bufferSize - index)

            let subdata = sourceData.subdata(in: index ..< index + rangeLength)
            index += rangeLength

            try outputFilter.write(subdata)

            if rangeLength == 0 {
                break
            }
        }

        return compressedData
    }
}
