//
//  Observer.swift
//  SotatekCore
//
//  Created by Loc Nguyen on 9/8/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation

public protocol Observer: class {
    func update(_ command: String, data: AnyObject?)
}
