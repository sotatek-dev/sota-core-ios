//
//  Array.swift
//  SotatekCore
//
//  Created by Thanh Tran on 9/8/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation

extension Array where Element : Equatable {
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(_ object : Element) {
        if let index = self.index(of: object) {
            self.remove(at: index)
        }
    }
    
    mutating func removeObjects(_ objects: [Element]) {
        for obj in objects {
            if let index = self.index(of: obj) {
                self.remove(at: index)
            }
        }
    }
}
