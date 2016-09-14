//
//  BaseRequest.swift
//  SotatekCore
//
//  Created by Loc Nguyen on 9/14/16.
//  Copyright © 2016 Thanh Tran. All rights reserved.
//

import Foundation
import RxSwift

public class BaseRequest<T: BaseEntity> {
    public func save(entity: T) -> Observable<T> {
        return Observable<T>.create({subscribe in
            subscribe.onNext(entity)
            subscribe.onCompleted()
            return AnonymousDisposable({})
        })
    }
    
    public func remove(entity: T) -> Observable<Bool> {
        return Observable<Bool>.create({subscribe in
            subscribe.onCompleted()
            return AnonymousDisposable({})
        })
    }
    
    public func get(id: Int64) -> Observable<T> {
        return Observable<T>.create({subscribe in
            
            subscribe.onNext(self.createDummyEntity(id)!)
            subscribe.onCompleted()
            return AnonymousDisposable({})
        })
    }
    
    func createDummyEntity(id: Int64) -> T? {
        let contact = ContactEntity(id: id, name: "Contact \(id)", avatarPath: "", online: true)
        let conversation = ConversationEntity(id: id, ownerId: 0, name: "Conversation \(id)", participantId: 1, createdAt: 0, unreadCount: 0, lastUpdate: 0, status: 0)
        
        if let contact = contact as? T {
            return contact
        }
        else if let conversation = conversation as? T {
            return conversation
        }
        return nil
    }
}