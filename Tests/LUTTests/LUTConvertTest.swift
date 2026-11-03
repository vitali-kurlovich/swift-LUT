//
//  LUTConvertTest.swift
//  swift-LUT
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

        let converter = CubeLUTConverter()

        let data = try converter.save(cube: cube)

        let cubeLoaded = try converter.load(data)

        #expect(cubeLoaded == cube)
    }
}
