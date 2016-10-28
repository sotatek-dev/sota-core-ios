//
//  BaseCache.swift
//  SotatekCore
//
//  Created by Thanh Tran on 9/8/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

open class BaseCache<T: BaseEntity>: Cache {
    var storage: BaseStorage<T>!
    var liveTime: Int = 1000 * 60 * 15 // 15 minutes
    
    init(storage: BaseStorage<T>) {
        self.storage = storage
    }
    
    private func fail() {
        fatalError("Please extend your cache from BaseListCache or BastMapCache.")
    }
    
    open func save(_ entity: T) {
        fail()
    }
    
    open func remove(_ entity: T) -> T {
        fail()
        return entity
    }
    
    open func get(_ id: Int) -> T? {
        fail()
        return nil
    }
    
    func getList(count: Int, options: [String: Any] = [:]) -> [T] {
        fail()
        return []
    }
    
    func getNextList(pivot: T, count: Int, options: [String: Any] = [:]) -> [T] {
        fail()
        return[]
    }
    
    func getAll(options: [String: Any] = [:]) -> [T] {
        fail()
        return[]
    }
    
    open func clear() {
        fail()
    }
    
    func updateValidTime(_ entity: T) {
        if liveTime > 0 {
            entity.validTime = Util.currentTime() + liveTime
        } else {
            entity.validTime = Int.max
        }
    }
    
    func save(_ json: JSON) -> AnyObject {
        let e = T(fromJson: json)
        updateValidTime(e)
        self.save(e)
        return e
    }
    
    func isCacheForEntity(name: String) -> Bool {
        return T.entityName == name || T.pluralName == name
    }
    
    open func save(_ entities: [T]) {
        for entity in entities {
            save(entity)
        }
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
    
    open func getAsync(_ id: Int) -> Observable<T> {
        return Observable<T>.create({subscribe in
            if let entity = self.get(id) {
                subscribe.onNext(entity)
            }
            subscribe.onCompleted()
            return Disposables.create()
        })
    }
    
    func getListAsync(count: Int, options: [String: Any] = [:]) -> Observable<[T]> {
        return Observable<[T]>.create({subscribe in
            var entities: [T]!
            if let pivot = options[Constant.RepositoryParam.pivot] as? T {
                entities = self.getNextList(pivot: pivot, count: count, options: options)
            } else {
                entities = self.getList(count: count, options: options)
            }
            print("Got \(entities.count) from cache")
            if entities.count >= count {
                subscribe.onNext(entities)
            }
            subscribe.onCompleted()
            return Disposables.create()
        })
    }
    
    func getAllAsync(options: [String: Any] = [:]) -> Observable<[T]> {
        return Observable<[T]>.create({subscribe in
            let entities = self.getAll(options: options)
            if entities.count > 0 {
                subscribe.onNext(entities)
            }
            subscribe.onCompleted()
            return Disposables.create()
        })
    }
}
