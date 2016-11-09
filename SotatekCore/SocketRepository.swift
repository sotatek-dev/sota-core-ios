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
    let notifier = Notifier.socketNoitfier
    
    var socketRequest = SocketRequest(namespace: Constant.SocketNamespace.liveStream)
    var dtoTypes = [BaseDto.entityName: BaseDto.self]
    var entityTypes = [BaseEntity.entityName: BaseEntity.self]
    
    init(namespace: String) {
    }
    
    open func connect(roomId: Int) {
        socketRequest.connect(roomId: roomId)
    }
    
    open func disconnect() {
        socketRequest.disconnect()
    }
    
    open func joinRoom(roomId: Int) {
        socketRequest.joinRoom(roomId)
    }
    
    open func addDataType(_ type: BaseDto.Type) {
//        dtoTypes[type.self.entityName] = type
        socketRequest.addDataEvent(type)
    }
    
    open func addDataType(_ type: BaseEntity.Type) {
//        entityTypes[type.self.entityName] = type
        socketRequest.addDataEvent(type)
    }
    
    open func onReceiveSocketData(json: JSON) {
        for (key,subJson): (String, JSON) in json {
            if let dtoType = dtoTypes[key] {
                let dto = dtoType.init(fromJson: subJson)
                notifier.notifyObservers(Constant.commandReceiveSocketData, data: SocketData(name: key, data: dto))
            } else if let entityType = entityTypes[key] {
                let entity = entityType.init(fromJson: subJson)
                notifier.notifyObservers(Constant.commandReceiveSocketData, data: SocketData(name: key, data: entity))
            } else {
                print("Unknown data type: \(key)")
            }
        }
    }
    
    open func send(_ data: Serializable) {
        socketRequest.send(data)
    }
}
