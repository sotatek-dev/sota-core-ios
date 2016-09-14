//
//  Util.swift
//  SotatekCore
//
//  Created by Loc Nguyen on 9/14/16.
//  Copyright © 2016 Thanh Tran. All rights reserved.
//

import Foundation

public class CoreUtil {
    public static func currentTime() -> Int64 {
        let time = NSDate().timeIntervalSince1970
        return Int64(time * 1000)
    }
}