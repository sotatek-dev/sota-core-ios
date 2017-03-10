//
//  Util.swift
//  SotatekCore
//
//  Created by Thanh Tran on 9/14/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation
import UIKit
import ReachabilitySwift

open class Util {
    static let reachability = Reachability()!

    static var isReachable: Bool {
        return reachability.isReachable
    }

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
    
    static func readTextFile(name: String, type: String = "") -> String {
        if let filepath = Bundle.main.path(forResource: name, ofType: type) {
            do {
                let contents = try String(contentsOfFile: filepath)
                return contents
            } catch {
                // contents could not be loaded
            }
        } else {
            // file not found!
        }
        return ""
    }
    
    static func readFile(name: String, type: String = "") -> NSData? {
        if let filepath = Bundle.main.path(forResource: name, ofType: type) {
            return NSData(contentsOfFile: filepath)
        } else {
            // file not found!
        }
        return nil
    }

    static func delay(_ delay: Double, _ function: @escaping (() -> Void)) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: {
            function()
        })
    }

}
