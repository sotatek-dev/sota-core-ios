//
//  SocketData.swift
//  SotatekCore
//
//  Created by Thanh Tran on 10/13/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation

open class SocketData {
    open var name: String
    open var data: Serializable
    
    init(name: String, data: Serializable) {
        self.name = name
        self.data = data
    }
}
