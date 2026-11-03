//
//  Created by Kurlovich Vitali on 9/18/26.
//

import CoreImage
import Foundation

public nonisolated struct CubeLUT: Hashable, Sendable {
    public enum Kind: Hashable, Sendable {
        /// Per-channel curves (`LUT_1D_SIZE`); `data` holds `dimension` float RGB triplets.
        case oneDimensional
        /// Color cube (`LUT_3D_SIZE`); `data` holds `dimension³` float RGBA values, red varying fastest.
        case threeDimensional
    }

    public var title: String
    public var description: String
    public let kind: Kind
    public let dimension: Int
    /// public let data: Data
    ///
    public let values: [Float]
    public let domainMin: SIMD3<Float>
    public let domainMax: SIMD3<Float>

    public init(
        title: String = "",
        description: String = "",
        kind: Kind,
        dimension: Int,
        values: [Float],
        domainMin: SIMD3<Float>,
        domainMax: SIMD3<Float>
    ) {
        self.title = title
        self.description = description
        self.kind = kind
        self.dimension = dimension
        self.values = values
        self.domainMin = domainMin
        self.domainMax = domainMax
    }
}

public extension CubeLUT {
    init(_ text: String) throws(CubeLUTError) {
        self = try parseCubeLUT(text)
    }

    init(_ data: Data) throws(CubeLUTError) {
        guard let text = String(data: data, encoding: .utf8) else {
            throw CubeLUTError.invalidFormat
        }
        try self.init(text)
    }

    init(_ url: URL) async throws(CubeLUTError) {
        self = try await parseCubeLUT(url.lines)
    }
}

public extension CubeLUT {
    var data: Data {
        values.withUnsafeBytes {
            Data($0)
        }
    }
}
