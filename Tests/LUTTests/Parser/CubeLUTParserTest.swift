//
//  Created by Kurlovich Vitali on 11/25/26.
//

import Foundation
@testable import LUT
import Testing

struct CubeLUTParserTest {
    @Test
    func parsePayload1D() throws {
        var parser = CubeLUTParser()

        let text = LUTContent1D.cubeTextContent

        let lines = text.components(separatedBy: .newlines)

        try parser.nextLine(lines[0])
        try parser.nextLine(lines[1])
        try parser.nextLine(lines[2])
        try parser.nextLine(lines[3])
        try parser.nextLine(lines[4])
        try parser.nextLine(lines[5])
        try parser.nextLine(lines[6])

        #expect(parser.isPayloadReady == false)

        try parser.nextLine(lines[7])

        #expect(parser.isPayloadReady == true)

        let meta = CubeLUTMeta(title: "Gamma 1.0 to HLG", description: "")

        let payload = CubeLUTPayload(
            meta: meta,
            kind: .oneDimensional,
            dimension: 4096,
            domainMin: .init(repeating: 0.0),
            domainMax: .init(repeating: 12.0000002924)
        )

        #expect(try parser.payload() == payload)
    }

    @Test
    func parsePayload3D() throws {
        var parser = CubeLUTParser()

        let text = LUTContent3D.cubeTextContent

        let lines = text.components(separatedBy: .newlines)

        try parser.nextLine(lines[0])
        try parser.nextLine(lines[1])
        try parser.nextLine(lines[2])
        try parser.nextLine(lines[3])
        try parser.nextLine(lines[4])
        try parser.nextLine(lines[5])
        try parser.nextLine(lines[6])

        #expect(parser.isPayloadReady == false)

        try parser.nextLine(lines[7])

        #expect(parser.isPayloadReady == true)

        let meta = CubeLUTMeta(title: "I02_rt", description: "")

        let payload = CubeLUTPayload(
            meta: meta,
            kind: .threeDimensional,
            dimension: 33,
            domainMin: .zero,
            domainMax: .one
        )

        #expect(try parser.payload() == payload)
    }
}
