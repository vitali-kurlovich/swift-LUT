//
//  Created by Kurlovich Vitali on 11/25/26.
//

import Foundation

private let newline = Data([0x0A]) // "\n"

struct FileLineReader {
    let url: URL
    let chunkSize: Int // = 256
    init(url: URL, chunkSize: Int = 256) {
        self.url = url
        self.chunkSize = chunkSize
    }

    func readLines(_ handler: (String) throws -> Bool) throws {
        let file = try FileHandle(forReadingFrom: url)
        defer {
            try? file.close()
        }
        var buffer = Data()

        while let chunk = try file.read(upToCount: chunkSize), !chunk.isEmpty {
            buffer.append(chunk)

            while let range = buffer.range(of: newline) {
                let lineData = buffer.subdata(in: buffer.startIndex ..< range.lowerBound)
                buffer.removeSubrange(buffer.startIndex ..< range.upperBound)

                if let line = String(data: lineData, encoding: .utf8), try handler(line) == false {
                    return
                }
            }
        }

        // Handle a final line with no trailing newline.
        if !buffer.isEmpty, let line = String(data: buffer, encoding: .utf8) {
            _ = try handler(line)
        }
    }
}

func forEachLine(
    at url: URL,
    chunkSize: Int = 256,
    handler: (String) throws -> Void
) throws {
    let file = try FileHandle(forReadingFrom: url)
    defer { try? file.close() }

    var buffer = Data()
    let newline = Data([0x0A]) // "\n"

    while let chunk = try file.read(upToCount: chunkSize), !chunk.isEmpty {
        buffer.append(chunk)

        while let range = buffer.range(of: newline) {
            let lineData = buffer.subdata(in: buffer.startIndex ..< range.lowerBound)
            buffer.removeSubrange(buffer.startIndex ..< range.upperBound)

            if let line = String(data: lineData, encoding: .utf8) {
                try handler(line)
            }
        }
    }

    // Handle a final line with no trailing newline.
    if !buffer.isEmpty, let line = String(data: buffer, encoding: .utf8) {
        try handler(line)
    }
}
