//
//  SocketRequest.swift
//  SotatekCore
//
//  Created by Thanh Tran on 10/13/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation
import SocketIO
import SwiftyJSON

public class SocketRequest {
    let notifier = Notifier.socketNoitfier
    let socket: SocketIOClient!
    var roomId: Int!
    
    init(namespace: String) {
        let connectParams = SocketIOClientOption.connectParams([Constant.requestAuthToken: AppConfig.authToken])
        let config: SocketIOClientConfiguration = [
            SocketIOClientOption.log(true),
            SocketIOClientOption.forcePolling(true),
            connectParams,
            SocketIOClientOption.nsp(namespace)]
        socket = SocketIOClient(socketURL: URL(string: AppConfig.server)!, config: config)
        socket.on("connect", callback: {data, ack in
            self.joinRoom(self.roomId)
        })
    }
    
    open func connect(roomId: Int) {
        self.roomId = roomId
        socket.connect()
        //startMock()
    }
    
    open func disconnect() {
        
    }
    
    open func joinRoom(_ roomId: Int) {
        self.roomId = roomId
        if socket.status == .connected {
            self.socket.emit("join-room", self.roomId)
        }
    }
    
    func addDataEvent(_ type: BaseEntity.Type) {
        socket.on(type.self.entityName, callback: {data, ack in
            let json = JSON(data)
            let entity = type.init(fromJson: json)
            self.notifier.notifyObservers(Constant.commandReceiveSocketData, data: SocketData(name: type.self.entityName, data: entity))
        })
    }
    
    func addDataEvent(_ type: BaseDto.Type) {
        socket.on(type.self.entityName, callback: {data, ack in
            print("Data from socket: \(data[0]) --")
            let json = JSON(data[0])
            let dto = type.init(fromJson: json)
            self.notifier.notifyObservers(Constant.commandReceiveSocketData, data: SocketData(name: type.self.entityName, data: dto))
        })
    }
    
    open func send(_ data: Serializable) {
//        if let message = data as? ChatLineEntity {
//            message.id = Util.currentTime()
//            let socketData = SocketData(name: "chatLine", data: message)
//            notifier.notifyObservers(Constant.commandReceiveSocketData, data: socketData)
//        }
        let json = JSON(data.toDictionary())
        socket.emit(type(of: data).entityName, json.rawString()!)
    }
    
    func startMock() {
        //let startTime = Util.currentTime()
        _ = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(notify), userInfo: nil, repeats: true)
    }
    
    @objc func notify() {
        
//        let id = Util.currentTime()
//        let time = Util.currentTime()
//        let chatLine = LiveChatLineDto(id: id, mediaId: 0, userId: 0, type: 0, content: "Message \(id)", createdAt: time, updatedAt: time)
//        let socketData = SocketData(name: "chatLine", data: chatLine)
//        notifier.notifyObservers(Constant.commandReceiveSocketData, data: socketData)
        
    }
}
