//
//  CubeLUT+PCubeLUT.swift
//  swift-LUT
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

extension CubeLUT {
    init(_ pCube: PCubeLUT) {
        let meta = pCube.meta

        self.init(
            title: meta.title,
            description: meta.description_p,
            kind: .init(pCube.kind),
            dimension: Int(pCube.dimension),
            values: pCube.data,
            domainMin: SIMD3<Float>(x: pCube.domainMin.x, y: pCube.domainMin.y, z: pCube.domainMin.z),
            domainMax: SIMD3<Float>(x: pCube.domainMax.x, y: pCube.domainMax.y, z: pCube.domainMax.z)
        )
    }
}
