//
//  Created by Kurlovich Vitali on 11/3/26.
//

import LUT
import Testing

struct LUTConvertTest {
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
    func cube3D() async throws {
        let text = LUTContent3D.cubeTextContent
        let cube = try CubeLUT(text)

        let expectedCube = LUTContent3D.cube

        #expect(expectedCube.payload == cube.payload)

        let cubeData = try await cube.data()
        let expData = try await expectedCube.data()

        #expect(expData == cubeData)
    }

    @Test
    func convert() async throws {
        let text = LUTContent3D.cubeTextContent
        let cube = try CubeLUT(text)

        let data = try await BCubeLUTIO.save(cube: cube)

        let cubeLoaded = try BCubeLUTIO.load(data)

        #expect(cubeLoaded.payload == cube.payload)

        let cubeData = try await cube.data()
        print(cubeData)
        let loadedData = try await cubeLoaded.data()
        print(loadedData)

        #expect(loadedData == cubeData)
    }
}
