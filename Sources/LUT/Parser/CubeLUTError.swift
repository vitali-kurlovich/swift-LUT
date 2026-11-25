//
//  Created by Kurlovich Vitali on 9/22/26.
//

import Foundation

public nonisolated enum CubeLUTError: Error, LocalizedError, Sendable {
    case IOError(Error)
    case invalidFormat
    case missingSize
    case invalidSize
    case mixed1D3DLUT
    case invalidDomain
    case invalidRow(line: Int)
    case incorrectRowCount(expected: Int, actual: Int)

    public var errorDescription: String? {
        switch self {
        case let .IOError(error):
            return "I/O error: \(error.localizedDescription)"
        case .invalidFormat:
            return "Invalid format."
        case .missingSize:
            return "Missing LUT_3D_SIZE."
        case .invalidSize:
            return "Invalid LUT_3D_SIZE."
        case .mixed1D3DLUT:
            return "Mixed 1D and 3D LUT"
        case .invalidDomain:
            return "Invalid DOMAIN_MIN or DOMAIN_MAX."
        case let .invalidRow(line):
            return "Invalid RGB data at line \(line)."
        case let .incorrectRowCount(expected, actual):
            return "Expected \(expected) rows, got \(actual)."
        }
    }
}
