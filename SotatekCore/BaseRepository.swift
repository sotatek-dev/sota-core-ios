//
//  BaseRepository.swift
//  SotatekCore
//
//  Created by Loc Nguyen on 9/14/16.
//  Copyright © 2016 Thanh Tran. All rights reserved.
//

import Foundation
import RxSwift

public class BaseRepository<T: BaseEntity> {
    var cache: BaseCache<T>!
    var request: BaseRequest<T>!
    
    init(cache: BaseCache<T>, request: BaseRequest<T>) {
        self.cache = cache
        self.request = request
    }
    
    public func save(entity: T) -> Observable<T> {
        let cachedEntity = cache.saveAsync(entity)
        let removeEntity = request.save(entity).map({(e: T) -> T in
            self.cache.save(e)
            return e
        })
        return cachedEntity.concat(removeEntity)
    }
    
    public func saveLocal(entity: T) -> Observable<T> {
        return cache.saveAsync(entity)
    }
    
    public func remove(entity: T) -> Observable<Bool> {
        return Observable<Bool>.create({subscribe in
            self.remove(entity)
            subscribe.onCompleted()
            return AnonymousDisposable({})
        })
    }
    
    public func get(id: Int64) -> Observable<T> {
        let cachedEntity = cache.getAsync(id)
        let remoteEntity = request.get(id).map({(e: T) -> T in
            self.cache.save(e)
            return e
        })
        return cachedEntity.concat(remoteEntity).take(1)
    }
}