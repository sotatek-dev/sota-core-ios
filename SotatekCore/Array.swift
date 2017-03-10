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
        var index = self.index(where: { element in
            if let entity = object as? BaseEntity, let element = element as? BaseEntity {
                return entity.id == element.id
            }
            return false
        })
        if index == nil {
            index = self.index(of: object)
        }
        if let index = index {
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
