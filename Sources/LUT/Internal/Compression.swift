//
//  Created by Kurlovich Vitali on 11/25/26.
//

import Compression
import Foundation

enum Compression {
    nonisolated static func decompress(_ data: Data, using algorithm: Algorithm = .lzma) throws -> Data {
        let compressedData = data
        var decompressedData = Data()
        let pageSize = 16 * 1024

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
        let pageSize = 1 << 16
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
