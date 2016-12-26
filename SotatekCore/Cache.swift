//
//  Cache.swift
//  SotatekCore
//
//  Created by Thanh Tran on 10/4/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol Cache {
    func isCacheForEntity(name: String) -> Bool
    func save(_ json: JSON) -> AnyObject
}
