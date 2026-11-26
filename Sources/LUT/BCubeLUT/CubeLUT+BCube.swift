//
//  Created by Kurlovich Vitali on 11/25/26.
//

import Foundation
import SwiftProtobuf

private let magic: UInt32 = 0x6275_6370

extension CubeLUT {
    func pCubeData() async throws -> Data {
        var pData = Data()
        pData.append(magic.littleEndianData)

        let pbPayload = PCubeLUTPayload(payload)

        let payloadData = try pbPayload.serializedData()
        let size = UInt32(payloadData.count)
        pData.append(size.littleEndianData)
        pData.append(payloadData)

        let data = try await data()

        let compressed = try Compression.compress(data, using: .lzma)

        pData.append(compressed)

        return pData
    }
}

/// CubeLUT+BCube
extension CubeLUT {
    init(bCubeData data: Data) throws(CubeLUTError) {
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

        do {
            let pPayload = try PCubeLUTPayload(serializedBytes: payloadData)

            let pointsRange = payloadRange.upperBound ..< data.endIndex

            let payload = CubeLUTPayload(pPayload)

            self.init(payload: payload) {
                let valuesData = data.subdata(in: pointsRange)

                return try Compression.decompress(valuesData, using: .lzma)
            }
        } catch {
            throw CubeLUTError.invalidFormat
        }
    }
}
