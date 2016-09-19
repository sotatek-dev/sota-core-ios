//
//  Util.swift
//  SotatekCore
//
//  Created by Loc Nguyen on 9/14/16.
//  Copyright © 2016 Thanh Tran. All rights reserved.
//

import Foundation

open class CoreUtil {
    open static func currentTime() -> Int64 {
        let time = Date().timeIntervalSince1970
        return Int64(time * 1000)
    }
    
    open static func uuid() -> String {
        return UUID().uuidString
    }
}
