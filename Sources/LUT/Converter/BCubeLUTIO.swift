//
//  Created by Kurlovich Vitali on 9/23/26.
//

import Compression
import Foundation
import SwiftProtobuf

public nonisolated struct BCubeLUTIO: Hashable, Sendable {}

private let magic: UInt32 = 0x62756370

public extension BCubeLUTIO {
    nonisolated static func load(_ url: URL, using algorithm: Algorithm = .lzma) throws -> CubeLUT {
        try load(Data(contentsOf: url), using: algorithm)
    }

    nonisolated static func save(cube: CubeLUT, to url: URL, using algorithm: Algorithm = .lzma) async throws {
        let data = try await save(cube: cube, using: algorithm)
        try data.write(to: url, options: .atomic)
    }
}

public extension BCubeLUTIO {
    nonisolated static func load(_ data: Data, using algorithm: Algorithm = .lzma) throws -> CubeLUT {
        let magicHeader = data.bytes.load(
            fromByteOffset: 0,
            as: UInt32.self
        ).littleEndian

        guard magic == magicHeader else {
            throw CubeLUTError.invalidFormat
        }

        let payloadSize = data.bytes.load(
            fromByteOffset: MemoryLayout<UInt32>.size,
            as: UInt32.self
        ).littleEndian

        let headerSize = 2 * MemoryLayout<UInt32>.size

        let payloadRange = headerSize ..< Int(payloadSize) + headerSize

        let payloadData = data[payloadRange]

        let pPayload = try PCubeLUTPayload(serializedBytes: payloadData)

        let pointsRange = payloadRange.upperBound ..< data.endIndex

        let payload = CubeLUTPayload(pPayload)

        let algorithmRaw = algorithm.rawValue.rawValue

        return CubeLUT(payload: payload) {
            let rawValue = compression_algorithm(algorithmRaw)
            let algorithm = Algorithm(rawValue: rawValue)!

            let valuesData = data.subdata(in: pointsRange)

            return try decompress(valuesData, using: algorithm)
        }
    }

    nonisolated static func save(cube: CubeLUT, using algorithm: Algorithm = .lzma) async throws -> Data {
        var pData = Data()
        pData.append(magic.littleEndianData)

        let pbPayload = PCubeLUTPayload(cube.payload)

        let payloadData = try pbPayload.serializedData()
        let size = UInt32(payloadData.count)
        pData.append(size.littleEndianData)
        pData.append(payloadData)

        let data = try await cube.data()
        
        let compressed = try compress(data, using: algorithm)

        pData.append(compressed)

        return pData
    }
}

extension FixedWidthInteger {
   

    var littleEndianData: Data {
        var value = littleEndian
        return Data(bytes: &value, count: MemoryLayout<Self>.size)
    }
}

private extension BCubeLUTIO {
    nonisolated static func decompress(_ data: Data, using algorithm: Algorithm = .lzma) throws -> Data {
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

        var index = compressedData.startIndex
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

    nonisolated static func compress(_ data: Data, using algorithm: Algorithm = .lzma) throws -> Data {
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
