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
    var socket: SocketIOClient!
    var roomId: DataIdType!
    
    init(namespace: String) {
        let connectParams = SocketIOClientOption.connectParams(createConnectParams())
        let config: SocketIOClientConfiguration = [
            SocketIOClientOption.log(false),
            SocketIOClientOption.forcePolling(true),
            connectParams,
            SocketIOClientOption.nsp(namespace)]
        socket = SocketIOClient(socketURL: URL(string: AppConfig.server)!, config: config)
        socket.on("connect", callback: {
            [unowned self] data, ack in
            self.joinRoom(self.roomId)
        })
        socket.on("room-changed", callback: {data, ack in
            self.notifier.notifyObservers(Constant.commandRoomChanged, data: data[0])
        })
    }

    func createConnectParams() -> [String: String] {
        return [:]
    }

    open func connectIfNeed() {
        if socket.status != .connected && socket.status != .connecting {
            socket.connect()
        }
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
            let json = JSON(data[0])
            print("Data from socket: \(json.rawString()) --")
            let entity = type.init(fromJson: json)
            self.notifier.notifyObservers(Constant.commandReceiveSocketData, data: SocketData(name: type.self.entityName, data: entity))
        })
    }

    
    func addDataEvent(_ type: BaseDto.Type) {
        socket.on(type.self.entityName, callback: {
            [unowned self] data, ack in
            let json = JSON(data[0])
            print("Data from socket: \(json.rawString()) --")
            let dto = type.init(fromJson: json)
            self.notifier.notifyObservers(Constant.commandReceiveSocketData, data: SocketData(name: type.self.entityName, data: dto))
        })
    }
    
    open func send(_ data: Serializable) {
        print("Send over socket: \(type(of: data).entityName) \(JSON(data.toDictionary()).rawString() ?? "")")
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
