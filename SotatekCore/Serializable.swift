//
//  Serializable.swift
//  SotatekCore
//
//  Created by Thanh Tran on 10/4/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation
import SwiftyJson

protocol Serializable {
    init(fromJson json: JSON!)
}
