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
    var roomId: DataIdType!
    
    init(namespace: String) {
        let connectParams = SocketIOClientOption.connectParams([Constant.requestAuthToken: AppConfig.authToken])
        let config: SocketIOClientConfiguration = [
            SocketIOClientOption.log(true),
            SocketIOClientOption.forcePolling(true),
            connectParams,
            SocketIOClientOption.nsp(namespace)]
        socket = SocketIOClient(socketURL: URL(string: AppConfig.server)!, config: config)
        socket.on("connect", callback: {
            [unowned self] data, ack in
            self.joinRoom(self.roomId)
        })
    }
    
    open func connect(roomId: DataIdType) {
        self.roomId = roomId
        socket.connect()
        //startMock()
    }
    
    open func disconnect() {
        socket.disconnect()
    }
    
    open func joinRoom(_ roomId: DataIdType) {
        self.roomId = roomId
        if socket.status == .connected {
            self.socket.emit("join-room", roomId)
        }
    }
    
    func addDataEvent(_ type: BaseEntity.Type) {
        socket.on(type.self.entityName, callback: {
            [unowned self] data, ack in
            print("Data from socket: \(data[0]) --")
            let json = JSON(data[0])
            let entity = type.init(fromJson: json)
            self.notifier.notifyObservers(Constant.commandReceiveSocketData, data: SocketData(name: type.self.entityName, data: entity))
        })
    }
    
    func addDataEvent(_ type: BaseDto.Type) {
        socket.on(type.self.entityName, callback: {
            [unowned self] data, ack in
            print("Data from socket: \(data[0]) --")
            let json = JSON(data[0])
            let dto = type.init(fromJson: json)
            self.notifier.notifyObservers(Constant.commandReceiveSocketData, data: SocketData(name: type.self.entityName, data: dto))
        })
    }
    
    open func send(_ data: Serializable) {
        socket.emit(type(of: data).entityName, data.toDictionary())
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
