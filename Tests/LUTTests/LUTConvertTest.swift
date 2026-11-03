//
//  Created by Kurlovich Vitali on 11/3/26.
//

import LUT
import Testing

struct LUTConvertTest {
    @Test
    func convert() throws {
        let text = LUTContent.cube
        let cube = try CubeLUT(text)

        let data = try BCubeLUTIO.save(cube: cube)

        let cubeLoaded = try BCubeLUTIO.load(data)

        #expect(cubeLoaded == cube)
    }
}
