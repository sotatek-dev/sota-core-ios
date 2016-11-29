//
//  BaseRepository.swift
//  SotatekCore
//
//  Created by Thanh Tran on 9/14/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

open class BaseRepository<T: BaseEntity> {
    var settingCacheSingleEntity: Bool {
        get {
            return cache.settingCacheSingleEntity
        }
        set {
            cache.settingCacheSingleEntity = newValue
        }
    }
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
            .flatMap(processMeta)
            .flatMap({(response: HttpResponse) -> Observable<T> in
                let savedEntity = T(fromJson: response.data)
                return self.cache.saveAsync(savedEntity)
            })
    }
    
    private func createLocalFirst(_ entity: T) -> Observable<T> {
        let cachedEntity = cache.saveAsync(entity)
        let remoteEntity = request.create(entity)
            .flatMap(processMeta)
            .flatMap({(response: HttpResponse) -> Observable<T> in
                let savedEntity = T(fromJson: response.data)
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
            .flatMap({(response: HttpResponse) -> Observable<T> in
                let savedEntity = T(fromJson: response.data)
                return self.cache.updateAsync(savedEntity)
            })
    }
    
    private func updateLocalFirst(_ entity: T) -> Observable<T> {
        return cache.saveAsync(entity).concat(
            request.update(entity)
                .flatMap({(response: HttpResponse) -> Observable<T> in
                    let savedEntity = T(fromJson: response.data)
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
    
    open func get(_ id: DataIdType) -> Observable<T> {
        let cachedEntity = cache.getAsync(id)
        let remoteEntity = request.get(id)
            .flatMap(processMeta)
            .map({(response: HttpResponse) -> T in
                let entity = self.saveJsonObject(response.data)
                return entity
            }
        )
        return Observable.first(cachedEntity, remoteEntity)
    }
    
    private func saveJsonObject(_ json: JSON) -> T {
        var entity: T!
        if json[T.entityName].exists() {
            for (key,subJson): (String, JSON) in json {
                let baseCache = CacheFactory.getCache(forEntity: key)
                let e = baseCache!.save(subJson)
                if T.entityName == key {
                    entity = e as! T
                }
            }
        } else {
            if self.settingCacheSingleEntity {
                entity = self.cache.save(json) as! T
            } else {
                entity = T(fromJson: json)
            }
        }
        return entity
    }
    
    func getList(count: Int, options: [String: Any] = [:]) -> Observable<ListDto<T>> {
        var cachedEntitiesObserver: Observable<ListDto<T>>!
        if let _ = options[Constant.RepositoryParam.pivot] as? T {
            _ = cache.removeAsync(options: options)
            cachedEntitiesObserver = Observable<ListDto<T>>.create {
                subcribe in
                subcribe.onNext(ListDto(data: [], pagination: nil))
                subcribe.onCompleted()
                return Disposables.create()
            }
            let remoteEntitiesObserver = request.getList(count: count, options: options)
                .flatMap(processMeta)
                .map{
                    (response: HttpResponse) -> ListDto<T> in
                    let entities = self.saveJsonList(response.data)
                    return ListDto(data: entities, pagination: response.pagination)
            }
            return Observable.first(remoteEntitiesObserver, cachedEntitiesObserver)
        }
        else {
            cachedEntitiesObserver = cache.getListAsync(count: count, options: options)
            let remoteEntitiesObserver = request.getList(count: count, options: options)
                .flatMap(processMeta)
                .map{
                    (response: HttpResponse) -> ListDto<T> in
                    let entities = self.saveJsonList(response.data)
                    return ListDto(data: entities, pagination: response.pagination)
            }
            return Observable.first(cachedEntitiesObserver, remoteEntitiesObserver)
        }
    }
    
    func saveJsonList(_ json: JSON) -> [T] {
        var entities = [T]()
        if let jsonArray = json.array {
            for jsonObject in jsonArray {
                let entity = cache.save(jsonObject) as! T
                entities.append(entity)
            }
        }
//        for (key,subJson): (String, JSON) in json {
//            let shouldAddToResult = T.entityName == key || T.pluralName == key
//            let baseCache = CacheFactory.getCache(forEntity: key)
//            guard baseCache != nil else {
//                continue
//            }
//            
//            if let jsonArray = subJson.array {
//                for jsonObject in jsonArray {
//                    let e = baseCache!.save(jsonObject)
//                    if shouldAddToResult {
//                        entities.append(e as! T)
//                    }
//                }
//            } else {
//                let e = baseCache!.save(subJson)
//                if shouldAddToResult {
//                    entities.append(e as! T)
//                }
//
//            }
//        }
        return entities
    }
    
    func getAll(options: [String: Any] = [:]) -> Observable<ListDto<T>> {
        let cachedEntitiesObserver = cache.getAllAsync(options: options)
        let remoteEntitiesObserver = request.getAll(options: options)
            .flatMap(processMeta)
            .map({(response: HttpResponse) -> ListDto<T> in
                let entities = self.saveJsonList(response.data)
                return ListDto<T>(data: entities, pagination: response.pagination)
            }
        )
        return Observable.first(cachedEntitiesObserver, remoteEntitiesObserver)
    }
    
    open func processMeta(response: HttpResponse) -> Observable<HttpResponse> {
        return Observable.just(response)
    }
}
