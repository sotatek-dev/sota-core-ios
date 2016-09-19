//
//  BaseMapCache.swift
//  SotatekCore
//
//  Created by Loc Nguyen on 9/19/16.
//  Copyright © 2016 Thanh Tran. All rights reserved.
//

import Foundation

//
//  BaseCache.swift
//  SotatekCore
//
//  Created by Loc Nguyen on 9/8/16.
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
        return nil
    }
    
    open override func clear() {
        map.removeAll()
    }
    
    override func getList(count: Int, options: [String: AnyObject] = [:]) -> [TEntity] {
        let groupId = options[CoreConstant.CACHE_GROUP_ID_VALUE] as! TGroupId
        var result: [TEntity];
        if let list = map[groupId] {
            result = Util.getHeadSubSet(list, count: count)
        }
        else {
            result = []
        }
        if result.count == count {
            return result
        }
        else {
            //TODO get from local db
            return result
        }
    }
    
    override func getNextList(pivot: TEntity, count: Int, options: [String: AnyObject] = [:]) -> [TEntity] {
        let groupId = options[CoreConstant.CACHE_GROUP_ID_VALUE] as! TGroupId
        var result: [TEntity]
        if let list = map[groupId] {
            result = Util.getSetOfBig(list, pivot: pivot, count: count)
        }
        else {
            result = []
        }
        return result
    }
}
