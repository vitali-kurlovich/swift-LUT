//
//  Created by Kurlovich Vitali on 11/3/26.
//

import LUT
import Testing

struct LUTConvertTest {
    @Test
    func convert() async throws {
        let text = LUTContent.cube
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
