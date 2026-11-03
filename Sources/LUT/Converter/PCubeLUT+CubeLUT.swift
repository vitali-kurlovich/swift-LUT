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
    init(_ meta: Meta) {
        self = .with {
            $0.title = meta.title ?? ""
            $0.description_p = meta.description ?? ""
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

extension PCubeLUT {
    init(_ cube: CubeLUT) {
        self = .with {
            $0.kind = PCubeLUTKind(cube.kind)
            $0.meta = PMeta(cube.meta)
            $0.dimension = .init(cube.dimension)
            $0.domainMin = PVector3D(cube.domainMin)
            $0.domainMax = PVector3D(cube.domainMax)
            $0.data = cube.values
        }
    }
}
