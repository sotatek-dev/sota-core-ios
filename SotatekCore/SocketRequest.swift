//
//  SocketRequest.swift
//  SotatekCore
//
//  Created by Thanh Tran on 10/13/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation

public class SocketRequest {
    let notifier = Notifier.socketNoitfier
    
    open func connect() {
        startMock()
    }
    
    open func disconnect() {
        
    }
    
    open func send(_ data: Serializable) {
        if let message = data as? ChatLineEntity {
            message.id = Util.currentTime()
            let socketData = SocketData(name: "chatLine", data: message)
            notifier.notifyObservers(Constant.commandReceiveSocketData, data: socketData)
        }
    }
    
    func startMock() {
        let startTime = Util.currentTime()
        _ = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(notify), userInfo: nil, repeats: true)
    }
    
    @objc func notify() {
        
        let id = Util.currentTime()
        let time = Util.currentTime()
        let chatLine = ChatLineEntity(id: id, mediaId: 0, userId: 0, type: 0, content: "Message \(id)", createdAt: time, updatedAt: time)
        let socketData = SocketData(name: "chatLine", data: chatLine)
        notifier.notifyObservers(Constant.commandReceiveSocketData, data: socketData)
        
    }
}
