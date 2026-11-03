//
//  Created by Kurlovich Vitali on 11/3/26.
//

import CoreImage.CIFilterBuiltins

public extension CubeLUT {
    var filter: CIFilter {
        switch kind {
        case .oneDimensional:
            let filter = CIFilter.colorCurves()

            filter.curvesData = data
            filter.curvesDomain = CIVector(x: CGFloat(domainMin.x), y: CGFloat(domainMax.x))
            return filter

        case .threeDimensional:
            let filter = CIFilter.colorCube()

            filter.cubeData = data
            filter.cubeDimension = Float(dimension)
            return filter
        }
    }
}
