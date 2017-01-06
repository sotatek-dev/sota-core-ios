//
//  BaseListCache.swift
//  SotatekCore
//
//  Created by Thanh Tran on 9/19/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import RxSwift

open class BaseListCache<T: BaseEntity>: BaseCache<T> {
    var data = [T]()
    
    open override func save(_ entity: T) {
        if settingCacheSingleEntity {
            addToCache(entity)
        }
        storage.save(entity)
    }
    
    open override func save(_ entities: [T]) {
        for entity in entities {
            save(entity)
        }
    }
    
    open override func remove(_ id: DataIdType) -> Bool {
        if let index = data.index(where: {$0.id == id}) {
            data.remove(at: index)
        }
        return storage.remove(id)
    }
    
    open override func remove(options: [String : Any]) -> [T] {
        if settingCacheSingleEntity {
            return []
        }

        let entities = self.storage.remove(options: options)
        data.removeObjects(entities)
        
        return entities
    }
    
    open override func get(_ id: DataIdType, options: [String : Any] = [:]) -> T? {
        var result: T?
        for entity in data {
            if entity.id == id {
                result = entity
            }
        }
        if result == nil {
            result = storage.get(id, options: options)
            if result != nil {
                if settingCacheSingleEntity {
                    addToCache(result!)
                }
            }
        }
        if let result = result {
            if result.validTime < Util.currentTime() {
                return nil
            }
        }
        return result
    }
    
    open override func getList(count: Int, options: [String: Any] = [:]) -> [T] {
        if settingCacheSingleEntity {
            return []
        }

        var result: [T];
        result = Util.getHeadSubSet(data, count: count)
        if result.count < count {
            result = storage.getList(count: count, options: options)
            if result.count < count {
                result = []
            }
            if !settingCacheSingleEntity {
                for e in result {
                    addToCache(e)
                }
            }
        }
        return result
    }
    
    open override func getNextList(pivot: T, count: Int, options: [String: Any] = [:]) -> [T] {
        if settingCacheSingleEntity {
            return []
        }

        var result: [T]
        result = Util.getSetOfBig(data, pivot: pivot, count: count)
        if result.count < count {
            result = storage.getNextList(pivot: pivot, count: count, options: options)
            if result.count < count {
                result = []
            }
            if !settingCacheSingleEntity {
                for e in result {
                    addToCache(e)
                }
            }
        }
        return result
    }
    
    open override func getAll(options: [String: Any] = [:]) -> [T] {
        var result = data
        if data.count == 0 {
            result = storage.getAll()
            data = [] + result
        }
        return result
    }
    
    open override func clear() {
        data.removeAll()
        storage.clear()
    }
    
    private func addToCache(_ e: T) {
        data.removeObject(e)
        data.append(e)
    }
}
