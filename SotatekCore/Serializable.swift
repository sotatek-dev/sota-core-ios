//
//  Serializable.swift
//  SotatekCore
//
//  Created by Thanh Tran on 10/4/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation
import SwiftyJSON

public protocol Serializable: class {
    var id: DataIdType! { get set }

    static var entityName: String {
        get
    }
    
    static var pluralName: String {
        get
    }
    
    init(fromJson json: JSON!)
    
    func toDictionary() -> Dictionary<String, Any>
}
