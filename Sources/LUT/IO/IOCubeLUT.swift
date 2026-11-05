//
//  Created by Kurlovich Vitali on 11/5/26.
//

import Foundation

public actor IOCubeLUT {
    private var taskStorage: [URL: Task<CubeLUT, Error>] = [:]

    private static let pcubeExtension = "pcube"
    private static let cubeExtension = "cube"

    private nonisolated(unsafe) let cache = {
        let cache = NSCache<NSURL, CubeLUTBox>()
        cache.totalCostLimit = 64 * 1024 * 1024
        return cache
    }()

    public static let shared = IOCubeLUT()

    private init() {}

    public func load(url: URL) async throws -> CubeLUT {
        if let cubeBox = cache.object(forKey: url as NSURL) {
            return cubeBox.cube
        }

        if let task = taskStorage[url] {
            let cube = try await task.value

            let box = CubeLUTBox(cube: cube)
            cache.setObject(box, forKey: url as NSURL, cost: cube.data.count)

            return cube
        }

        if url.pathExtension.lowercased() == Self.pcubeExtension {
            let task = Task {
                try BCubeLUTIO.load(url)
            }
            taskStorage[url] = task
            return try await loadCube(url: url, task: task)

        } else if url.pathExtension.lowercased() == Self.cubeExtension {
            let task = Task {
                try await CubeLUT(url)
            }
            taskStorage[url] = task
            return try await loadCube(url: url, task: task)
        } else {
            throw CubeLUTError.invalidFormat
        }
    }

    private func loadCube(url: URL, task: Task<CubeLUT, Error>) async throws -> CubeLUT {
        let cube = try await task.value

        let box = CubeLUTBox(cube: cube)
        cache.setObject(box, forKey: url as NSURL, cost: cube.data.count)

        taskStorage.removeValue(forKey: url)

        return cube
    }

    private final class CubeLUTBox {
        let cube: CubeLUT

        init(cube: CubeLUT) {
            self.cube = cube
        }
    }
}
