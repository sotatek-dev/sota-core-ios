//
//  Random.swift
//  SotatekChat
//
//  Created by Thanh Tran on 9/19/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation

public extension Int {
    public static func random(lower: Int = min, upper: Int = max) -> Int {
        let r = Int(arc4random()) % (upper - lower)
        return Int(r + lower)
    }
}

public extension CGFloat {
    public static func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }

    public static func random(lower: CGFloat = leastNormalMagnitude, upper: CGFloat = greatestFiniteMagnitude) -> CGFloat {
        return CGFloat.random() * (upper - lower) + lower
    }
}

public extension Float {
    public static func random(lower: Float = Float(leastNormalMagnitude), upper: Float = greatestFiniteMagnitude) -> Float {
        return Float(CGFloat.random(lower: CGFloat(lower), upper: CGFloat(upper)))
    }
}
