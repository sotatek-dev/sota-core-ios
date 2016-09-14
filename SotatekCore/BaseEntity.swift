//
//  BaseEntity.swift
//  SotatekCore
//
//  Created by Loc Nguyen on 9/8/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation

public class BaseEntity: Comparable, Hashable {
    public var id: Int64
    public var compareValue: Int64 = 0
    
    public var hashValue: Int {
        get {
            return id.hashValue
        }
    }
    
    public init(id: Int64) {
        self.id = id
    }
}

public func < (lhs: BaseEntity, rhs: BaseEntity) -> Bool {
    return lhs.compareValue < rhs.compareValue
}

public func <= (lhs: BaseEntity, rhs: BaseEntity) -> Bool {
    return lhs.hashValue == rhs.hashValue || lhs.compareValue < rhs.compareValue
}

public func > (lhs: BaseEntity, rhs: BaseEntity) -> Bool {
    return lhs.compareValue > rhs.compareValue
}

public func >= (lhs: BaseEntity, rhs: BaseEntity) -> Bool {
    return lhs.hashValue == rhs.hashValue || lhs.compareValue > rhs.compareValue
}

public func == (lhs: BaseEntity, rhs: BaseEntity) -> Bool {
    return lhs.hashValue == rhs.hashValue
}