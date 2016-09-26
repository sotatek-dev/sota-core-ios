//
//  BaseRepository.swift
//  SotatekCore
//
//  Created by Thanh Tran on 9/14/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation
import RxSwift

open class BaseRepository<T: BaseEntity> {
    var settingCacheSingleEntity = true
    var settingSyncRemoteFirst = true
    
    var cache: BaseCache<T>!
    var request: BaseRequest<T>!
    
    init(cache: BaseCache<T>, request: BaseRequest<T>) {
        self.cache = cache
        self.request = request
    }
    
    open func create(_ entity: T) -> Observable<T> {
        return settingSyncRemoteFirst ? createRemoteFirst(entity) : createLocalFirst(entity)
    }
    
    private func createRemoteFirst(_ entity: T) -> Observable<T> {
        return self.request.create(entity)
            .flatMap({saveEntity in
                return self.cache.saveAsync(saveEntity)
            })
    }
    
    private func createLocalFirst(_ entity: T) -> Observable<T> {
        let cachedEntity = cache.saveAsync(entity)
        let remoteEntity = request.create(entity)
            .flatMap({savedEntity -> Observable<T> in
                self.didCreateCompleted(savedEntity)
                return self.cache.saveAsync(savedEntity)
            })
            .catchError({error in
                self.didCreateError(entity)
                return self.cache.saveAsync(entity).concat(Observable.error(error))
            })
        return cachedEntity.concat(remoteEntity)
    }
    
    open func update(_ entity: T) -> Observable<T> {
        return settingSyncRemoteFirst ? updateRemoteFirst(entity) : updateLocalFirst(entity)
    }
    
    private func updateRemoteFirst(_ entity: T) -> Observable<T> {
        return self.request.update(entity)
            .flatMap({saveEntity in
                return self.cache.updateAsync(saveEntity)
            })
    }
    
    private func updateLocalFirst(_ entity: T) -> Observable<T> {
        return cache.saveAsync(entity).concat(
            request.update(entity)
                .flatMap({(savedEntity: T) -> Observable<T> in
                    self.didUpdateCompleted(savedEntity)
                    return self.cache.saveAsync(savedEntity)
                })
                .catchError({error in
                    self.didUpdateError(entity)
                    return self.cache.saveAsync(entity).concat(Observable.error(error))
                })
        )
    }
    
    open func didCreateError(_ entity: T) {
        
    }
    
    open func didCreateCompleted(_ entity: T) {
        
    }
    
    open func didUpdateError(_ entity: T) {
        
    }
    
    open func didUpdateCompleted(_ entity: T) {
        
    }
    
    open func saveLocal(_ entity: T) -> Observable<T> {
        return cache.saveAsync(entity)
    }

    open func remove(_ entity: T) -> Observable<T> {
        return settingSyncRemoteFirst ? removeRemoteFirst(entity) : removeLocalFirst(entity)
    }
    
    private func removeRemoteFirst(_ entity: T) -> Observable<T> {
        return request.remove(entity).flatMap({entity in
            return self.cache.removeAsync(entity)
        })
    }
    
    private func removeLocalFirst(_ entity: T) -> Observable<T> {
        return cache.removeAsync(entity).concat(
            request.remove(entity)
                .catchError({error in
                    _ = self.cache.saveAsync(entity)
                    return Observable.error(error)
                })
        )
    }
    
    open func get(_ id: Int64) -> Observable<T> {
        let cachedEntity = cache.getAsync(id)
        let remoteEntity = request.get(id).map({(e: T) -> T in
            if self.settingCacheSingleEntity {
                self.cache.save(e)
            }
            return e
        })
        return Observable.first(cachedEntity, remoteEntity)
    }
    
    func getList(count: Int, options: [String: Any] = [:]) -> Observable<[T]> {
        let cachedEntitiesObserver = cache.getListAsync(count: count, options: options)
        let remoteEntitiesObserver = request.getList(count: count, options: options).flatMap({(entities: [T]) -> Observable<[T]> in
            return self.cache.saveAsync(entities)
        })
        return Observable.first(cachedEntitiesObserver, remoteEntitiesObserver)
    }
    
    func getNextList(pivot: T, count: Int, options: [String: Any] = [:]) -> Observable<[T]> {
        let cachedEntitiesObserver = cache.getNextListAsync(pivot: pivot, count: count, options: options)
        let remoteEntitiesObserver = request.getNextList(pivot: pivot, count: count, options: options).flatMap({(entities: [T]) -> Observable<[T]> in
            return self.cache.saveAsync(entities)
        })
        return Observable.first(cachedEntitiesObserver, remoteEntitiesObserver)
    }
}
