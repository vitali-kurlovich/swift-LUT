//
//  Created by Kurlovich Vitali on 11/3/26.
//

extension CubeLUT.Kind {
    init(_ kind: PCubeLUTKind) {
        switch kind {
        case .oneDimensional:
            self = .oneDimensional
        case .threeDimensional:
            self = .threeDimensional
        case .UNRECOGNIZED:
            self = .threeDimensional
        }
    }
}

extension CubeLUTMeta {
    init(_ meta: PMeta) {
        self.init(title: meta.title, description: meta.description_p)
    }
}

extension CubeLUTPayload {
    init(_ payload: PCubeLUTPayload) {
        self.init(
            meta: CubeLUTMeta(payload.meta),
            kind: Kind(payload.kind),
            dimension: .init(payload.dimension),
            domainMin: SIMD3<Float>(x: payload.domainMin.x, y: payload.domainMin.y, z: payload.domainMin.z),
            domainMax: SIMD3<Float>(x: payload.domainMax.x, y: payload.domainMax.y, z: payload.domainMax.z)
        )
    }
}
