//
//  BaseStorage.swift
//  SotatekCore
//
//  Created by Thanh Tran on 9/22/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation
import SQLite

public class BaseStorage<T: BaseEntity> {
    let db: Connection!
    let table: Table!
    
    public init(_ db: Connection) {
        self.db = db
        table = Table(T.entityName)
        try! _ = db.run(table.create(ifNotExists: true) { t in
            T.createTable(builder: t)
        })
    }
    
    open func save(_ entity: T) {
        if get(entity.id) != nil {
            try! _ = db.run(table.update(entity.columnValues))
        }
        else {
            try! _ = db.run(table.insert(entity.columnValues))
        }
    }
    
    open func remove(_ entity: T) -> T {
        let filter = table.filter(T.idColumn == 1)
        try! _ = db.run(filter.delete())
        return entity
    }
    
    open func get(_ id: Int64) -> T? {
        let filter = table.filter(T.idColumn == id)
        if let row = try! db.pluck(filter) {
            return (T.toEntity(row) as! T)
        }
        else {
            return nil
        }
    }
    
    func getList(count: Int, options: [String: Any] = [:]) -> [T] {
        var query = table!
        if let filter = options[Constant.REPOSITORY_DB_FILTER] as? Expression<Bool> {
            query = table.filter(filter)
        }
        query = query.limit(count)
        return toEntities(query)
    }
    
    func getNextList(pivot: T, count: Int, options: [String: Any] = [:]) -> [T] {
        var query = table!
        let filter = getFilter(pivot: pivot, options: options)
        query = table.filter(filter)
        query = query.limit(count)
        return toEntities(query)
    }
    
    func getAll(options: [String: Any] = [:]) -> [T] {
        var query = table!
        if let filter = options[Constant.REPOSITORY_DB_FILTER] as? Expression<Bool> {
            query = table.filter(filter)
        }
        return toEntities(query)
    }
    
    func getFilter(pivot: T, options: [String: Any] = [:]) -> Expression<Bool> {
        var filter: Expression<Bool> = pivot.nextFilter
        if let originFilter = options[Constant.REPOSITORY_DB_FILTER] as? Expression<Bool> {
            filter = originFilter && filter
        }
        return filter
    }
    
    func toEntities(_ query: QueryType) -> [T] {
        var entities = [T]()
        for row in try! db.prepare(query) {
            entities.append(T.toEntity(row) as! T)
        }
        return entities
    }
    
    open func clear() {
        try! _ = db.run(table.delete())
    }
}
