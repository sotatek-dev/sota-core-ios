//
//  Observer.swift
//  SotatekCore
//
//  Created by Thanh Tran on 9/8/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation

public protocol Observer: class {
    func update(_ command: Int, data: Any?)
}
