//
//  BaseMapCache.swift
//  SotatekCore
//
//  Created by Thanh Tran on 9/19/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

open class BaseMapCache<TGroupId: Hashable, TEntity: BaseEntity>: BaseCache<TEntity> {
    var map = [TGroupId: [TEntity]]()

    func getGroupId(_ entity: TEntity) -> TGroupId? {
        fatalError("getGroupId must be implemented")
    }
    
    func getGroupId(options: [String: Any]) -> TGroupId? {
        fatalError("getGroupId must be implemented")
    }
    
    open override func save(_ entity: TEntity) {
        addToCache(entity)
        storage.save(entity)
    }
    
    open override func save(_ entities: [TEntity]) {
        for entity in entities {
            save(entity)
        }
    }
    
    open override func remove(_ entity: TEntity) -> TEntity {
        let key = getGroupId(entity)!
        if var list = map[key] {
            list.removeObject(entity)
        }
        _ = storage.remove(entity)
        return entity
    }
    
    open override func remove(options: [String : Any]) -> [TEntity] {
        let entities = self.storage.remove(options: options)
        for ent in entities {
            let key = getGroupId(ent)!
            _ = map[key]?.removeObject(ent)
        }
        
        return entities
    }
    
    open override func get(_ id: DataIdType) -> TEntity? {
        for list in map.values {
            for entity in list {
                if entity.id == id {
                    return entity
                }
            }
        }
        if let entity = storage.get(id) {
            let groupId = getGroupId(entity)!
            map[groupId] = map[groupId] ?? [] + [entity]
            
            return entity
        }
        
        return nil
    }
    
    open override func clear() {
        map.removeAll()
        storage.clear()
    }
    
    override func getList(count: Int, options: [String: Any] = [:]) -> [TEntity] {
        let groupId = getGroupId(options: options)!
        var result: [TEntity] = [];
        if let list = map[groupId] {
            result = Util.getHeadSubSet(list, count: count)
        }
        if result.count < count {
            result = storage.getList(count: count, options: options)
            if result.count < count {
                result = []
            }
            map[groupId] = map[groupId] ?? [] + result
        }
        return result
    }
    
    override func getNextList(pivot: TEntity, count: Int, options: [String: Any] = [:]) -> [TEntity] {
        let groupId = getGroupId(options: options)!
        var result: [TEntity] = []
        if let list = map[groupId] {
            result = Util.getSetOfBig(list, pivot: pivot, count: count)
        }
        if result.count < count {
            result = storage.getNextList(pivot: pivot, count: count, options: options)
            if result.count < count {
                result = []
            }
            map[groupId] = map[groupId] ?? [] + result
        }
        return result
    }
    
    open override func getAll(options: [String: Any] = [:]) -> [TEntity] {
        let groupId = getGroupId(options: options)!
        var result = map[groupId] ?? []
        if result.count == 0 {
            result = storage.getAll(options: options)
            map[groupId] = [] + result
        }
        return result
    }

    private func addToCache(_ e: TEntity) {
        let key = getGroupId(e)!
        var list = map[key] ?? []
        list.removeObject(e)
        list.append(e)
        map[key] = list
    }
}
