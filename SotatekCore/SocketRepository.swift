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
    
    var socketRequest: SocketRequest
    var dtoTypes = [BaseDto.entityName: BaseDto.self]
    var entityTypes = [BaseEntity.entityName: BaseEntity.self]
    
    init(namespace: String) {
        socketRequest = SocketRequest(namespace: namespace)
    }
    
    open func connect(roomId: DataIdType) {
        socketRequest.connect(roomId: roomId)
    }
    
    open func disconnect() {
        socketRequest.disconnect()
    }
    
    open func joinRoom(roomId: DataIdType) {
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
    
    open func send(_ data: Serializable) {
        socketRequest.send(data)
    }
}
