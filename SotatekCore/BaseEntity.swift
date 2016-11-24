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
    open var id: DataIdType!
    open var compareValue: Int = 0
    open var validTime: Int = 0
    
    override open var hashValue: Int {
        get {
            //return id.hashValue
            return 0
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
    
    public init(id: DataIdType) {
        self.id = id
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(validTime, forKey: "validTime")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "id") as! DataIdType
        self.validTime = aDecoder.decodeInteger(forKey: "validTime")
    }
    
    public required init(fromJson json: JSON!) {
        if let value = json["id"].object as? DataIdType {
            self.id = value
        }
    }
    
    public func toDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        dictionary["id"] = id
        return dictionary
    }
    
    public func clone() -> BaseEntity {
        let entity = BaseEntity(id: self.id)
        entity.validTime = validTime
        return entity
    }
    
    public static let idColumn = Expression<DataIdType>("id")
    public static let validTimeColumn = Expression<Int>("validTime")
    
    open class func createTable(builder: TableBuilder) {
        builder.column(Expression<DataIdType>("id"))
        builder.column(Expression<Int>("validTime"))
    }
    
    open class func toEntity(_ row: Row) -> BaseEntity {
        let e = BaseEntity(id: row[BaseEntity.idColumn])
        e.validTime = row[BaseEntity.validTimeColumn]
        return e
    }
    
    open var columnValues: [Setter]! {
        get {
            return [
                BaseEntity.idColumn <- self.id,
                BaseEntity.validTimeColumn <- self.validTime
            ]
        }
    }
    
    open var nextFilter: Expression<Bool> {
        get {
            fatalError("Please implement nextFilter")
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
