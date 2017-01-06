//
//  CacheFactory.swift
//  SotatekCore
//
//  Created by Thanh Tran on 10/4/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation

class CacheFactory {
    static var caches = [Cache]()

    static func addCache(_ cache: Cache) {
        caches.append(cache)
    }
    
    open static func getCache(forEntity name: String) -> Cache? {
        for cache in caches {
            if cache.isCacheForEntity(name: name) {
                return cache
            }
        }
        return nil
    }
}
