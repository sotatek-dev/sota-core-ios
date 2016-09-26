//
//  BaseListCache.swift
//  SotatekCore
//
//  Created by Thanh Tran on 9/19/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation

open class BaseListCache<T: BaseEntity>: BaseCache<T> {
    var data = [T]()
    
    open override func save(_ entity: T) {
        data.removeObject(entity)
        data.append(entity)
        storage.save(entity)
    }
    
    open override func save(_ entities: [T]) {
        for entity in entities {
            save(entity)
        }
    }
    
    open override func remove(_ entity: T) -> T {
        data.removeObject(entity)
        _ = storage.remove(entity)
        return entity
    }
    
    open override func get(_ id: Int64) -> T? {
        for entity in data {
            if entity.id == id {
                return entity
            }
        }
        return storage.get(id)
    }
    
    open override func getList(count: Int, options: [String: Any] = [:]) -> [T] {
        var result: [T];
        result = Util.getHeadSubSet(data, count: count)
        if result.count < count {
            result = storage.getList(count: count, options: options)
            if result.count < count {
                result = []
            }
        }
        return result
    }
    
    open override func getNextList(pivot: T, count: Int, options: [String: Any] = [:]) -> [T] {
        var result: [T]
        result = Util.getSetOfBig(data, pivot: pivot, count: count)
        if result.count < count {
            result = storage.getNextList(pivot: pivot, count: count, options: options)
            if result.count < count {
                result = []
            }
        }
        return result
    }
    
    open override func clear() {
        data.removeAll()
        storage.clear()
    }
}
