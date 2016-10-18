//
//  BaseEntity.swift
//  SotatekCore
//
//  Created by Thanh Tran on 9/8/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation
import SQLite
import SwiftyJSON

open class BaseEntity: NSObject, Comparable, NSCoding, Serializable {
    open var id: Int
    open var compareValue: Int = 0
    
    override open var hashValue: Int {
        get {
            return id.hashValue
        }
    }
    
    open static var entityName: String {
        get {
            var name = String(describing: self)
            let lowercase = String(name[name.startIndex]).lowercased()
            name.replaceSubrange(name.startIndex...name.startIndex, with: lowercase)
            if name.hasSuffix("Entity") {
                name = name.substring(to: name.index(name.endIndex, offsetBy: -"Entity".characters.count))
            }
            return name
        }
    }
    
    open static var pluralName: String {
        get {
            return entityName + "s"
        }
    }
    
    public init(id: Int) {
        self.id = id
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeInteger(forKey: "id")
    }
    
    public required init(fromJson json: JSON!) {
        self.id = json["id"].intValue
    }
    
    public func toDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        dictionary["id"] = id
        return dictionary
    }
    
    public func clone() -> BaseEntity {
        return BaseEntity(id: self.id)
    }
    
    public static let idColumn = Expression<Int>("id")
    
    open class func createTable(builder: TableBuilder) {
        builder.column(Expression<Int>("id"))
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
