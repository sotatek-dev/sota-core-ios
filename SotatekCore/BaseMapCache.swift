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

    func getGroupId(_ entity: TEntity) -> TGroupId {
        fatalError("getGroupId must be implemented")
    }
    
    final func getGroupId(options: [String: Any]) -> TGroupId {
        if let groupId = options[Constant.RepositoryParam.groupId] as? TGroupId {
            return groupId
        }
        fatalError("Parameter options has to contain value for key groupId")
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
    
    open override func remove(_ id: DataIdType) -> Bool {
        for (key, list) in map {
            if let index = list.index(where: {$0.id == id}) {
                var newList = list
                newList.remove(at: index)
                map[key] = newList
                break
            }
        }
        return storage.remove(id)
    }
    
    open override func remove(options: [String : Any]) -> [TEntity] {
        let entities = self.storage.remove(options: options)
        for ent in entities {
            let key = getGroupId(ent)
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
            addToCache(entity)
            
            return entity
        }
        
        return nil
    }
    
    open override func clear() {
        map.removeAll()
        storage.clear()
    }
    
    override func getList(count: Int, options: [String: Any] = [:]) -> [TEntity] {
        let groupId = getGroupId(options: options)
        var result: [TEntity] = [];
        if let list = map[groupId] {
            result = Util.getHeadSubSet(list, count: count)
        }
        if result.count < count {
            result = storage.getList(count: count, options: options)
            if result.count < count {
                result = []
            }
            addToCache(result)
        }
        return result
    }
    
    override func getNextList(pivot: TEntity, count: Int, options: [String: Any] = [:]) -> [TEntity] {
        let groupId = getGroupId(options: options)
        var result: [TEntity] = []
        if let list = map[groupId] {
            result = Util.getSetOfBig(list, pivot: pivot, count: count)
        }
        if result.count < count {
            result = storage.getNextList(pivot: pivot, count: count - result.count, options: options)
            addToCache(result)
        }
        return result
    }
    
    open override func getAll(options: [String: Any] = [:]) -> [TEntity] {
        let groupId = getGroupId(options: options)
        var result = map[groupId] ?? []
        if result.count == 0 {
            result = storage.getAll(options: options)
            map[groupId] = result
        }
        return result
    }

    private func addToCache(_ e: TEntity) {
        let key = getGroupId(e)
        var list = map[key] ?? []
        list.removeObject(e)
        list.append(e)
        map[key] = list
    }
    
    private func addToCache(_ result: [TEntity]) {
        guard result.count > 0 else {
            return
        }
        
        let key = getGroupId(result.first!)
        var list = map[key] ?? []
        for el in result {
            if list.index(of: el) == nil {
                list.append(el)
            }
        }
        
        map[key] = list
    }
}
