//
//  BaseRequest.swift
//  SotatekCore
//
//  Created by Loc Nguyen on 9/14/16.
//  Copyright © 2016 Thanh Tran. All rights reserved.
//

import Foundation
import RxSwift

open class BaseRequest<T: BaseEntity> {
    var NETWORK_DELAY: Int64 = 1
    var id: Int64 = 0
    
    open func create(_ entity: T) -> Observable<T> {
        return Observable<T>.create({subscribe in
            self.delay({
                self.id += 1
                entity.id = self.id
                subscribe.onNext(entity)
                subscribe.onCompleted()
            })
            return Disposables.create()
        })
    }
    
    open func update(_ entity: T) -> Observable<T> {
        return Observable<T>.create({subscribe in
            self.delay({
                subscribe.onNext(entity)
                subscribe.onCompleted()
            })
            return Disposables.create()
        })
    }
    
    open func remove(_ entity: T) -> Observable<T> {
        return Observable<T>.create({subscribe in
            self.delay({
                if Int.random() % 2 == 0 {
                    subscribe.onNext(entity)
                }
                else {
                    subscribe.onError(NSError())
                }
                subscribe.onCompleted()
            })
            return Disposables.create()
        })
    }
    
    open func get(_ id: Int64) -> Observable<T> {
        return Observable<T>.create({subscribe in
            self.delay({
                subscribe.onNext(self.createDummyEntity(id)!)
                subscribe.onCompleted()
            })
            return Disposables.create()
        })
    }
    
    func getList(count: Int, options: [String: AnyObject]) -> Observable<[T]> {
        return Observable<[T]>.create({subscribe in
            self.delay({
                var entities = [T]()
                for i in 0..<count {
                    entities.append(self.createDummyEntity(Int64(i), options: options)!)
                }
                print("Got \(entities.count) from server")
                subscribe.onNext(entities)
                subscribe.onCompleted()
            })
            return Disposables.create()
        })
    }
    
    func getNextList(pivot: T, count: Int, options: [String: AnyObject]) -> Observable<[T]> {
        return Observable<[T]>.create({subscribe in
            self.delay({
                var entities = [T]()
                for i in 0..<count {
                    entities.append(self.createDummyEntity(Int64(i), options: options)!)
                }
                print("Got \(entities.count) from server")
                subscribe.onNext(entities)
                subscribe.onCompleted()
            })
            return Disposables.create()
        })
    }
    
    func createDummyEntity(_ id: Int64, options: [String: AnyObject] = [:]) -> T? {
        let contact = ContactEntity(id: id, name: "Contact \(id)", avatarPath: "", online: true)
        let conversation = ConversationEntity(id: id, ownerId: 0, name: "Conversation \(id)", participantId: 1, createdAt: 0, unreadCount: 0, lastUpdate: 0, status: 0)
        let message = MessageEntity(id: self.id, conversationId: 0, timestamp: CoreUtil.currentTime() + id, text: "Message \(id)", senderId: 0, status: 0)
        
        if let contact = contact as? T {
            print("Get contact \(id) from server")
            return contact
        }
        else if let conversation = conversation as? T {
            print("Get conversation \(id) from server")
            return conversation
        }
        else if let m = message as? T {
            print("Get message \(id) from server")
            message.conversationId = options[CoreConstant.CACHE_GROUP_ID_VALUE] as! Int64
            return m
        }
        return nil
    }
    
    func delay(_ f: @escaping () -> Void) {
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.asyncAfter(deadline: .now() + Double(NETWORK_DELAY)) {
            DispatchQueue.main.async(execute: { () -> Void in
                f()
            })
        }
    }
}
