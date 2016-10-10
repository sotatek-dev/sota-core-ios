//
//  Observer.swift
//  SotatekCore
//
//  Created by Thanh Tran on 9/8/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation

@objc public protocol Observer: class {
    func update(_ command: String, data: AnyObject?)
}
