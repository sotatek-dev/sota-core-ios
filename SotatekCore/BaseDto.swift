//
//  BaseDto.swift
//  SotatekCore
//
//  Created by Thanh Tran on 10/5/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation
import SwiftyJSON

class BaseDto: NSObject, NSCoding, Serializable {
    open var id: DataIdType!

    open static var entityName: String {
        get {
            var name = String(describing: self)
            let lowercase = String(name[name.startIndex]).lowercased()
            name.replaceSubrange(name.startIndex...name.startIndex, with: lowercase)
            if name.hasSuffix("Dto") {
                name = name.substring(to: name.index(name.endIndex, offsetBy: -"Dto".characters.count))
            }
            return name
        }
    }
    
    open static var pluralName: String {
        get {
            return entityName + "s"
        }
    }
    
    open func encode(with aCoder: NSCoder) {
    }
    
    override init() {}
    
    public required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeInteger(forKey: "id")
    }
    
    public required init(fromJson json: JSON!) {
        self.id = json["id"].intValue
    }
    
    public func toDictionary() -> [String : Any] {
        let dictionary = [String: Any]()
        return dictionary
    }
}
