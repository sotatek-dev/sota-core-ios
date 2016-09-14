//
//  BaseCache.swift
//  SotatekCore
//
//  Created by Loc Nguyen on 9/8/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class BaseCache<T: BaseEntity> {
    var data = [T]()
    
    public func save(entity: T) {
        data.removeObject(entity)
        data.append(entity)
    }
    
    public func save(entities: [T]) {
        for entity in entities {
            save(entity)
        }
    }
    
    public func remove(entity: T) -> T {
        data.removeObject(entity)
        return entity
    }
    
    public func get(id: Int64) -> T? {
        for entity in data {
            if entity.id == id {
                return entity
            }
        }
        return nil
    }
    
    public func getAll() -> [T] {
        return [] + data
    }
    
    public func clear() {
        data.removeAll()
    }
    
    public func saveAsync(entity: T) -> Observable<T> {
        return Observable<T>.create({subscribe in
            self.data.removeObject(entity)
            self.data.append(entity)
            subscribe.onNext(entity)
            subscribe.onCompleted()
            return AnonymousDisposable({})
        })
    }
    
    public func saveAsync(entities: [T]) -> Observable<[T]> {
        return Observable<[T]>.create({subscribe in
            self.save(entities)
            subscribe.onNext(entities)
            subscribe.onCompleted()
            return AnonymousDisposable({})
        })
    }
    
    public func removeAsync(entity: T) -> Observable<Bool> {
        return Observable<Bool>.create({subscribe in
            self.remove(entity)
            subscribe.onCompleted()
            return AnonymousDisposable({})
        })
    }
    
    public func getAsync(id: Int64) -> Observable<T> {
        return Observable<T>.create({subscribe in
            if let entity = self.get(id) {
                subscribe.onNext(entity)
            }
            subscribe.onCompleted()
            return AnonymousDisposable({})
        })
    }
    
    public func getAll() -> Observable<[T]> {
        return Observable<[T]>.create({subscribe in
            subscribe.onNext([] + self.data)
            subscribe.onCompleted()
            return AnonymousDisposable({})
        })
    }
}