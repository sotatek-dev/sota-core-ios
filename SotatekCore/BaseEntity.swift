//
//  BaseEntity.swift
//  SotatekCore
//
//  Created by Thanh Tran on 9/8/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation
import SQLite

open class BaseEntity: Comparable, Hashable {
    open var id: Int64
    open var compareValue: Int64 = 0
    
    open var hashValue: Int {
        get {
            return id.hashValue
        }
    }
    
    public init(id: Int64) {
        self.id = id
    }
    
    public func clone() -> BaseEntity {
        return BaseEntity(id: self.id)
    }
    
    public static let idColumn = Expression<Int64>("id")
    
    open class func createTable(builder: TableBuilder) {
        builder.column(Expression<Int64>("id"))
    }
    
    open class func toEntity(_ row: Row) -> BaseEntity {
        let e = BaseEntity(id: row[BaseEntity.idColumn])
        return e
    }
    
    open var columnValues: [Setter]! {
        get {
            return []
        }
    }
    
    open var nextFilter: Expression<Bool> {
        get {
            return BaseEntity.idColumn > 0
        }
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
