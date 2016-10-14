//
//  BaseMapCache.swift
//  SotatekCore
//
//  Created by Thanh Tran on 9/19/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation

//
//  BaseCache.swift
//  SotatekCore
//
//  Created by Thanh Tran on 9/8/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

open class BaseMapCache<TGroupId: Hashable, TEntity: BaseEntity>: BaseCache<TEntity> {
    var map = [TGroupId: [TEntity]]()

    func getGroupId(_ entity: TEntity) -> TGroupId? {
        return nil
    }

    open override func save(_ entity: TEntity) {
        let key = getGroupId(entity)!
        var list = map[key] ?? []
        list.removeObject(entity)
        list.append(entity)
        map[key] = list
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
    
    open override func get(_ id: Int64) -> TEntity? {
        for list in map.values {
            for entity in list {
                if entity.id == id {
                    return entity
                }
            }
        }
        return storage.get(id)
    }
    
    open override func clear() {
        map.removeAll()
        storage.clear()
    }
    
    override func getList(count: Int, options: [String: Any] = [:]) -> [TEntity] {
        let groupId = options[Constant.REPOSITORY_GROUP_ID] as! TGroupId
        var result: [TEntity] = [];
        if let list = map[groupId] {
            result = Util.getHeadSubSet(list, count: count)
        }
        if result.count < count {
            result = storage.getList(count: count, options: options)
            if result.count < count {
                result = []
            }
        }
        return result
    }
    
    override func getNextList(pivot: TEntity, count: Int, options: [String: Any] = [:]) -> [TEntity] {
        let groupId = options[Constant.REPOSITORY_GROUP_ID] as! TGroupId
        var result: [TEntity] = []
        if let list = map[groupId] {
            result = Util.getSetOfBig(list, pivot: pivot, count: count)
        }
        if result.count < count {
            result = storage.getNextList(pivot: pivot, count: count, options: options)
            if result.count < count {
                result = []
            }
        }
        return result
    }
    
    open override func getAll(options: [String: Any] = [:]) -> [TEntity] {
        let groupId = options[Constant.REPOSITORY_GROUP_ID] as! TGroupId
        var result = map[groupId] ?? []
        if result.count == 0 {
            result = storage.getAll(options: options)
        }
        return result
    }
}
