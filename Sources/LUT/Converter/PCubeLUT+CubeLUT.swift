//
//  Created by Kurlovich Vitali on 11/3/26.
//

extension PVector3D {
    init(_ simd: SIMD3<Float>) {
        self = .with {
            $0.x = simd.x
            $0.y = simd.y
            $0.z = simd.z
        }
    }
}

extension PMeta {
    init(_ meta: CubeLUTMeta) {
        self = .with {
            $0.title = meta.title
            $0.description_p = meta.description
        }
    }
}

extension PCubeLUTPayload {
    init(_ payload: CubeLUTPayload) {
        self = .with {
            $0.domainMin = .init(payload.domainMin)
            $0.domainMax = .init(payload.domainMax)

            $0.kind = PCubeLUTKind(payload.kind)
            $0.dimension = .init(payload.dimension)

            $0.meta = PMeta(payload.meta)
        }
    }
}

extension PCubeLUTKind {
    init(_ kind: CubeLUT.Kind) {
        switch kind {
        case .oneDimensional:
            self = .oneDimensional
        case .threeDimensional:
            self = .threeDimensional
        }
    }
}
