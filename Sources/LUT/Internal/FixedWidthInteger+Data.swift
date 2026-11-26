//
//  Created by Kurlovich Vitali on 11/25/26.
//

import Foundation

extension FixedWidthInteger {
    var littleEndianData: Data {
        var value = littleEndian
        return Data(bytes: &value, count: MemoryLayout<Self>.size)
    }
}
