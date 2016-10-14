//
//  SocketRepository.swift
//  SotatekCore
//
//  Created by Thanh Tran on 10/13/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation
import SwiftyJSON

class SocketRepository {
    public static var instance = SocketRepository()
    let notifier = Notifier.socketNoitfier
    
    var socketRequest = SocketRequest()
    var dtoTypes = [BaseEntity.entityName: BaseDto.self]
    
    private init() {
    }
    
    open func addDataType(_ type: BaseDto.Type) {
        dtoTypes[type.self.entityName] = type
    }
    
    open func onReceiveData(json: JSON) {
        for (key,subJson): (String, JSON) in json {
            if let baseCache = CacheFactory.getCache(forEntity: key) {
                let entity = baseCache.save(subJson) as! Serializable
                notifier.notifyObservers(Constant.COMMAND_RECEIVE_DATA, data: SocketData(name: key, data: entity))
            }
            else if let dtoType = dtoTypes[key] {
                let dto = dtoType.init(fromJson: json)
                notifier.notifyObservers(Constant.COMMAND_RECEIVE_DATA, data: SocketData(name: key, data: dto))
            }
            else {
                print("Unknown data type: \(key)")
            }
        }
    }
}
