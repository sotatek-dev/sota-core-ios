//
//  BaseListCache.swift
//  SotatekCore
//
//  Created by Loc Nguyen on 9/19/16.
//  Copyright © 2016 Thanh Tran. All rights reserved.
//

import Foundation

open class BaseListCache<T: BaseEntity>: BaseCache<T> {
    var data = [T]()
    
    open override func save(_ entity: T) {
        data.removeObject(entity)
        data.append(entity)
    }
    
    open override func save(_ entities: [T]) {
        for entity in entities {
            save(entity)
        }
    }
    
    open override func remove(_ entity: T) -> T {
        data.removeObject(entity)
        return entity
    }
    
    open override func get(_ id: Int64) -> T? {
        for entity in data {
            if entity.id == id {
                return entity
            }
        }
        return nil
    }
    
    open override func getList(count: Int, options: [String: AnyObject] = [:]) -> [T] {
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
    
    open override func getNextList(pivot: T, count: Int, options: [String: AnyObject] = [:]) -> [T] {
        var result: [T]
        result = Util.getSetOfBig(data, pivot: pivot, count: count)
        return result
    }
    
    open override func clear() {
        data.removeAll()
    }
}
