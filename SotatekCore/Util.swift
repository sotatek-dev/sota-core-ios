//
//  Util.swift
//  SotatekCore
//
//  Created by Thanh Tran on 9/14/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation
import UIKit

open class Util {
    open static func currentTime() -> Int64 {
        let time = Date().timeIntervalSince1970
        return Int64(time * 1000)
    }
    
    open static func uuid() -> String {
        return UUID().uuidString
    }
    
    open static func createViewController(storyboardName: String, id: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: id)
    }
}
