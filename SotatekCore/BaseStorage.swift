//
//  BaseStorage.swift
//  SotatekCore
//
//  Created by Thanh Tran on 9/22/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation
import SQLite

public class BaseStorage<T: BaseEntity>: Storage {
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
            let e = table.filter(T.idColumn == entity.id)
            try! _ = db.run(e.update(entity.columnValues))
        } else {
            try! _ = db.run(table.insert(entity.columnValues))
        }
    }
    
    open func remove(_ id: DataIdType) -> Bool {
        let filter = table.filter(T.idColumn == id)
        try! _ = db.run(filter.delete())
        return true
    }
    
    open func get(_ id: DataIdType) -> T? {
        let filter = table.filter(T.idColumn == id)
        if let row = try! db.pluck(filter) {
            return (T.toEntity(row) as! T)
        } else {
            return nil
        }
    }
    
    func getList(count: Int, options: [String: Any] = [:]) -> [T] {
        var query = table!
        if let filter = options[Constant.RepositoryParam.dbFilter] as? Expression<Bool> {
            query = table.filter(filter)
        }
        query = query.limit(count)
        let result = toEntities(query)
        print("getList: count: \(count) ---> Got \(result.count) entities from \(String(describing: self)))")
        return result
    }
    
    func getNextList(pivot: T, count: Int, options: [String: Any] = [:]) -> [T] {
        var query = table!
        let filter = getFilter(pivot: pivot, options: options)
        query = table.filter(filter)
        query = query.limit(count)
        let result = toEntities(query)
        print("getNextList: pivot: \(pivot) count: \(count) ---> Got \(result.count) entites from \(String(describing: self)))")
        return result
    }
    
    func getAll(options: [String: Any] = [:]) -> [T] {
        var query = table!
        if let filter = options[Constant.RepositoryParam.dbFilter] as? Expression<Bool> {
            query = table.filter(filter)
        }
        return toEntities(query)
    }
    
    func getFilter(pivot: T, options: [String: Any] = [:]) -> Expression<Bool> {
        var filter: Expression<Bool> = pivot.nextFilter
        if let originFilter = options[Constant.RepositoryParam.dbFilter] as? Expression<Bool> {
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
    
    open func remove(options: [String: Any]) -> [T] {
        var query = table!
        if let pivot = options[Constant.RepositoryParam.pivot] as? T {
            let filter = getFilter(pivot: pivot, options: options)
            query = table.filter(filter)
        }
        else if let originFilter = options[Constant.RepositoryParam.dbFilter] as? Expression<Bool> {
            query = table.filter(originFilter)
        }
        let result = toEntities(query)
        
        try! _ = db.run(query.delete())
        
        return result
    }

    func migrate(fromVersion: Int, toVersion: Int) {
        if let statement = T.migrate(table, fromVersion: fromVersion, toVersion: toVersion) {
            try! db.run(statement)
        }
    }
}
