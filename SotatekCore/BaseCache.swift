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

open class BaseCache<T: BaseEntity> {
    var data = [T]()
    
    open func save(_ entity: T) {
        data.removeObject(entity)
        data.append(entity)
    }
    
    open func save(_ entities: [T]) {
        for entity in entities {
            save(entity)
        }
    }
    
    open func remove(_ entity: T) -> T {
        data.removeObject(entity)
        return entity
    }
    
    open func get(_ id: Int64) -> T? {
        for entity in data {
            if entity.id == id {
                return entity
            }
        }
        return nil
    }

    
    open func clear() {
        data.removeAll()
    }
    
    open func saveAsync(_ entity: T) -> Observable<T> {
        return Observable<T>.create({subscribe in
            self.save(entity)
            subscribe.onNext(entity)
            subscribe.onCompleted()
            return Disposables.create()
        })
    }
    
    open func saveAsync(_ entities: [T]) -> Observable<[T]> {
        return Observable<[T]>.create({subscribe in
            self.save(entities)
            subscribe.onNext(entities)
            subscribe.onCompleted()
            return Disposables.create()
        })
    }
    
    open func updateAsync(_ entity: T) -> Observable<T> {
        return Observable<T>.create({subscribe in
            //TODO implement
            _ = self.save(entity)
            subscribe.onNext(entity)
            subscribe.onCompleted()
            return Disposables.create()
        })
    }
    
    open func removeAsync(_ entity: T) -> Observable<T> {
        return Observable<T>.create({subscribe in
            _ = self.remove(entity)
            subscribe.onNext(entity)
            subscribe.onCompleted()
            return Disposables.create()
        })
    }
    
    open func getAsync(_ id: Int64) -> Observable<T> {
        return Observable<T>.create({subscribe in
            if let entity = self.get(id) {
                subscribe.onNext(entity)
            }
            subscribe.onCompleted()
            return Disposables.create()
        })
    }
    
    func getList(count: Int, options: [String: AnyObject] = [:]) -> [T] {
        var result: [T];
        result = Util.getHeadSubSet(data, count: count)
        if result.count == count {
            return result
        }
        else {
            //TODO get from local db
            return result
        }
    }
    
    func getNextList(pivot: T, count: Int, options: [String: AnyObject] = [:]) -> [T] {
        var result: [T]
        result = Util.getSetOfBig(data, pivot: pivot, count: count)
        return result
    }
    
    func getListAsync(count: Int, options: [String: AnyObject] = [:]) -> Observable<[T]> {
        return Observable<[T]>.create({subscribe in
            let entities = self.getList(count: count, options: options)
            print("Got \(entities.count) from cache")
            if entities.count >= count {
                subscribe.onNext(entities)
            }
            subscribe.onCompleted()
            return Disposables.create()
        })
    }
    
    func getNextListAsync(pivot: T, count: Int, options: [String: AnyObject] = [:]) -> Observable<[T]> {
        return Observable<[T]>.create({subscribe in
            let entities = self.getNextList(pivot: pivot, count: count, options: options)
            print("Got \(entities.count) from cache")
            if entities.count >= count {
                subscribe.onNext(entities)
            }
            subscribe.onCompleted()
            return Disposables.create()
        })
    }
}
