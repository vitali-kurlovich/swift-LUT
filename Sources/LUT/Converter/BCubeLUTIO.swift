//
//  Created by Kurlovich Vitali on 9/23/26.
//

import Compression
import Foundation

public nonisolated struct BCubeLUTIO: Hashable, Sendable {}

public extension BCubeLUTIO {
    nonisolated static func load(_ url: URL) throws -> CubeLUT {
        try load(Data(contentsOf: url))
    }

    nonisolated static func save(cube: CubeLUT, to url: URL) async throws {
        let data = try await save(cube: cube)
        try data.write(to: url, options: .atomic)
    }
}

public extension BCubeLUTIO {
    nonisolated static func load(_ data: Data) throws -> CubeLUT {
        try CubeLUT(bCubeData: data)
    }

    nonisolated static func save(cube: CubeLUT) async throws -> Data {
        try await cube.pCubeData()
    }
}
