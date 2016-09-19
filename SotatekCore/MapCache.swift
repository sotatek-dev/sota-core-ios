//
//  MapCache.swift
//  SotatekCore
//
//  Created by Loc Nguyen on 9/19/16.
//  Copyright © 2016 Thanh Tran. All rights reserved.
//

import Foundation

protocol MapCache {
    associatedtype TGroupId
    associatedtype TEntity
    func getGroupId(entity: TEntity) -> TGroupId
}
