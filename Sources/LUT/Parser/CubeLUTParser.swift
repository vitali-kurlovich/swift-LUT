//
//  Created by Kurlovich Vitali on 9/22/26.
//

import CryptoKit
import Foundation

private struct CubeLUTParser: Sendable {
    private var title: String?

    private var size1D: Int?
    private var size3D: Int?
    private var domainMin = SIMD3<Float>(repeating: 0)
    private var domainMax = SIMD3<Float>(repeating: 1)
    private var rgbValues: [SIMD3<Float>] = []

    private var lineNumber = 0

    private var isFinalized: Bool = false

    mutating func nextLine<S: StringProtocol>(_ rawLine: S) throws(CubeLUTError) {
        assert(isFinalized == false)

        lineNumber += 1

        let line = rawLine
            .split(separator: "#", maxSplits: 1, omittingEmptySubsequences: false)
            .first?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard line.isEmpty == false else { return }
        guard line != "\n" else { return }

        let parts = line.split {
            $0 == " " || $0 == "\t" || $0 == ","
        }

        guard let keyword = parts.first else { return }

        switch keyword.uppercased() {
        case "TITLE":
            title = parts.dropFirst().joined(separator: " ")

        case "LUT_1D_SIZE":
            guard parts.count >= 2,
                  let size = Int(parts[1]),
                  (2 ... 65536).contains(size)
            else {
                throw CubeLUTError.invalidSize
            }

            size1D = size

        case "LUT_3D_SIZE":
            guard parts.count >= 2,
                  let size = Int(parts[1]),
                  (2 ... 256).contains(size)
            else {
                throw CubeLUTError.invalidSize
            }

            size3D = size

        // Resolve's variant of DOMAIN_MIN / DOMAIN_MAX: one range for all channels.
        case "LUT_1D_INPUT_RANGE", "LUT_3D_INPUT_RANGE":
            guard parts.count >= 3,
                  let min = Float(parts[1]),
                  let max = Float(parts[2])
            else {
                throw CubeLUTError.invalidDomain
            }

            domainMin = SIMD3(repeating: min)
            domainMax = SIMD3(repeating: max)

        case "DOMAIN_MIN":
            guard parts.count >= 4,
                  let r = Float(parts[1]),
                  let g = Float(parts[2]),
                  let b = Float(parts[3])
            else {
                throw CubeLUTError.invalidDomain
            }

            domainMin = SIMD3(r, g, b)

        case "DOMAIN_MAX":
            guard parts.count >= 4,
                  let r = Float(parts[1]),
                  let g = Float(parts[2]),
                  let b = Float(parts[3])
            else {
                throw CubeLUTError.invalidDomain
            }

            domainMax = SIMD3(r, g, b)

        default:
            guard parts.count == 3,
                  let r = Float(parts[0]),
                  let g = Float(parts[1]),
                  let b = Float(parts[2])
            else {
                return
            }

            rgbValues.append(SIMD3(r, g, b))
        }
    }

    mutating func finalize() throws(CubeLUTError) -> CubeLUT {
        isFinalized = true

        guard all(domainMin .< domainMax) else {
            throw CubeLUTError.invalidDomain
        }

        switch (size1D, size3D) {
        case let (size?, nil):
            return try finalize1D(size: size)
        case let (nil, size?):
            return try finalize3D(size: size)
        case (.some, .some):
            throw CubeLUTError.mixed1D3DLUT
        case (nil, nil):
            throw CubeLUTError.missingSize
        }
    }

    private func finalize1D(size: Int) throws(CubeLUTError) -> CubeLUT {
        guard rgbValues.count == size else {
            throw CubeLUTError.incorrectRowCount(
                expected: size,
                actual: rgbValues.count
            )
        }

        // CIColorCurves takes a single domain for all three curves.
        guard domainMin.x == domainMin.y, domainMin.x == domainMin.z,
              domainMax.x == domainMax.y, domainMax.x == domainMax.z
        else {
            throw CubeLUTError.invalidDomain
        }

        var rgbFloats = [Float]()
        rgbFloats.reserveCapacity(size * 3)

        for rgb in rgbValues {
            rgbFloats.append(rgb.x)
            rgbFloats.append(rgb.y)
            rgbFloats.append(rgb.z)
        }

        return CubeLUT(
            title: title ?? "",
            kind: .oneDimensional,
            dimension: size,
            values: rgbFloats,
            domainMin: domainMin,
            domainMax: domainMax
        )
    }

    private func finalize3D(size dimension: Int) throws(CubeLUTError) -> CubeLUT {
        let expectedCount = dimension * dimension * dimension

        guard rgbValues.count == expectedCount else {
            throw CubeLUTError.incorrectRowCount(
                expected: expectedCount,
                actual: rgbValues.count
            )
        }

        var rgbaValues = [Float]()
        rgbaValues.reserveCapacity(expectedCount * 4)

        for rgb in rgbValues {
            rgbaValues.append(rgb.x)
            rgbaValues.append(rgb.y)
            rgbaValues.append(rgb.z)
            rgbaValues.append(1.0)
        }

        return CubeLUT(
            title: title ?? "",
            description: "",
            kind: .threeDimensional,
            dimension: dimension,
            values: rgbaValues,
            domainMin: domainMin,
            domainMax: domainMax
        )
    }
}

func parseCubeLUT<S: AsyncSequence>(_ lines: S) async throws(CubeLUTError) -> CubeLUT where S.Element == String {
    var parser = CubeLUTParser()

    do {
        for try await rawLine in lines {
            try parser.nextLine(rawLine)
        }

    } catch let error as CubeLUTError {
        throw error
    } catch {
        throw CubeLUTError.IOError(error)
    }

    return try parser.finalize()
}

func parseCubeLUT(_ text: String) throws(CubeLUTError) -> CubeLUT {
    var parser = CubeLUTParser()

    let lines = text.components(separatedBy: .newlines)

    for rawLine in lines {
        try parser.nextLine(rawLine)
    }

    return try parser.finalize()
}
