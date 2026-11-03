//
//  CubeLUT+Meta.swift
//  swift-LUT
//
//  Created by Kurlovich Vitali on 11/3/26.
//

import Foundation

public struct Meta: Hashable, Sendable {
    public let title: String?
    public let description: String?
}

public extension CubeLUT {
    var meta: Meta {
        return Meta(title: title, description: description)
    }
}
