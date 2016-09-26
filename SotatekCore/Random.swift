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
        let r = Int(arc4random())
        return Int(Int(r) + lower)
    }
}
