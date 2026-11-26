//
//  Created by Kurlovich Vitali on 11/25/26.
//

import Foundation
import LUT
import Testing

struct LUTTest {
    @Test
    func cube1D() async throws {
        let text = LUTContent1D.cubeTextContent
        let cube = try CubeLUT(text)

        let expectedCube = LUTContent1D.cube

        #expect(expectedCube.payload == cube.payload)

        let cubeData = try await cube.data()
        let expData = try await expectedCube.data()

        #expect(expData == cubeData)
    }

    @Test
    func cube1DPayload() throws {
        let text = LUTContent1D.cubeTextContent

        let cube = try CubeLUT(text)
        let meta = CubeLUTMeta(title: "Gamma 1.0 to HLG", description: "")

        let payload = CubeLUTPayload(
            meta: meta,
            kind: .oneDimensional,
            dimension: 4096,
            domainMin: .init(repeating: 0.0),
            domainMax: .init(repeating: 12.0000002924)
        )

        #expect(cube.payload == payload)
    }

    @Test
    func cube1DFormUrl() async throws {
        // 1. Get the system temporary directory URL
        let tempDir = FileManager.default.temporaryDirectory

        // 2. Create a unique filename for isolation
        let fileURL = tempDir.appendingPathComponent(UUID().uuidString + ".cube")

        // 3. Clean up the file automatically when the test finishes
        defer {
            try? FileManager.default.removeItem(at: fileURL)
        }

        let data = try #require(LUTContent1D.cubeTextContent.data(using: .utf8))

        // 4. Write mock data to the temporary file
        try data.write(to: fileURL, options: [.atomic])

        let cube = try CubeLUT(fileURL)

        #expect(cube.payload == LUTContent1D.cube.payload)

        let expData = try await LUTContent1D.cube.data()
        let cubeData = try await cube.data()

        #expect(expData == cubeData)
    }

    @Test
    func pCube1DFormUrl() async throws {
        // 1. Get the system temporary directory URL
        let tempDir = FileManager.default.temporaryDirectory

        // 2. Create a unique filename for isolation
        let fileURL = tempDir.appendingPathComponent(UUID().uuidString + ".pcube")

        // 3. Clean up the file automatically when the test finishes
        defer {
            try? FileManager.default.removeItem(at: fileURL)
        }

        // 4. Write mock data to the temporary file
        try await BCubeLUTIO.save(cube: LUTContent1D.cube, to: fileURL)

        let cube = try CubeLUT(fileURL)

        #expect(cube.payload == LUTContent1D.cube.payload)

        let expData = try await LUTContent1D.cube.data()
        let cubeData = try await cube.data()

        #expect(expData == cubeData)
    }

    @Test
    func cube3DFormUrl() async throws {
        // 1. Get the system temporary directory URL
        let tempDir = FileManager.default.temporaryDirectory

        // 2. Create a unique filename for isolation
        let fileURL = tempDir.appendingPathComponent(UUID().uuidString + ".cube")

        // 3. Clean up the file automatically when the test finishes
        defer {
            try? FileManager.default.removeItem(at: fileURL)
        }

        let data = try #require(LUTContent3D.cubeTextContent.data(using: .utf8))

        // 4. Write mock data to the temporary file
        try data.write(to: fileURL, options: [.atomic])

        let cube = try CubeLUT(fileURL)

        #expect(cube.payload == LUTContent3D.cube.payload)

        let expData = try await LUTContent3D.cube.data()
        let cubeData = try await cube.data()

        #expect(expData == cubeData)
    }

    @Test
    func pCube3DFormUrl() async throws {
        // 1. Get the system temporary directory URL
        let tempDir = FileManager.default.temporaryDirectory

        // 2. Create a unique filename for isolation
        let fileURL = tempDir.appendingPathComponent(UUID().uuidString + ".pcube")

        // 3. Clean up the file automatically when the test finishes
        defer {
            try? FileManager.default.removeItem(at: fileURL)
        }

        // 4. Write mock data to the temporary file
        try await BCubeLUTIO.save(cube: LUTContent3D.cube, to: fileURL)

        let cube = try CubeLUT(fileURL)

        #expect(cube.payload == LUTContent3D.cube.payload)

        let expData = try await LUTContent3D.cube.data()
        let cubeData = try await cube.data()

        #expect(expData == cubeData)
    }

    @Test
    func cube3DPayload() throws {
        let text = LUTContent3D.cubeTextContent
        let cube = try CubeLUT(text)

        let meta = CubeLUTMeta(title: "I02_rt", description: "")

        let payload = CubeLUTPayload(
            meta: meta,
            kind: .threeDimensional,
            dimension: 33,
            domainMin: .zero,
            domainMax: .one
        )

        #expect(cube.payload == payload)
    }

    @Test
    func payload3DFormUrl() throws {
        // 1. Get the system temporary directory URL
        let tempDir = FileManager.default.temporaryDirectory

        // 2. Create a unique filename for isolation
        let fileURL = tempDir.appendingPathComponent(UUID().uuidString + ".cube")

        // 3. Clean up the file automatically when the test finishes
        defer {
            try? FileManager.default.removeItem(at: fileURL)
        }

        let data = try #require(LUTContent3D.cubeTextContent.data(using: .utf8))

        // 4. Write mock data to the temporary file
        try data.write(to: fileURL, options: [.atomic])

        let cube = try CubeLUT(fileURL)

        #expect(cube.payload == LUTContent3D.cube.payload)
    }

    @Test
    func cube3D() async throws {
        let text = LUTContent3D.cubeTextContent
        let cube = try CubeLUT(text)

        let expectedCube = LUTContent3D.cube

        #expect(expectedCube.payload == cube.payload)

        let cubeData = try await cube.data()
        let expData = try await expectedCube.data()

        #expect(expData == cubeData)
    }
}
