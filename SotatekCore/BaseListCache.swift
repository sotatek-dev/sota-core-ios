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
    
    open override func get(_ id: DataIdType) -> T? {
        var result: T?
        for entity in data {
            if entity.id == id {
                result = entity
            }
        }
        if result == nil {
            result = storage.get(id)
            if result != nil {
                data.append(result!)
            }
        }
        if let result = result {
            if result.validTime > Util.currentTime() {
                return nil
            }
        }
        return result
    }
    
    open override func getList(count: Int, options: [String: Any] = [:]) -> [T] {
        var result: [T];
        result = Util.getHeadSubSet(data, count: count)
        if result.count < count {
            result = storage.getList(count: count, options: options)
            if result.count < count {
                result = []
            }
            data += result
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
            data += result
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
}
