//
//  Constant.swift
//  SotatekCore
//
//  Created by Thanh Tran on 9/19/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation

class Constant {
    class RepositoryParam {
        static let groupId = "groupId"
        static let requestParams = "request_params"
        static let dbFilter = "db_filter"
        static let cacheFilter = "cache_filter"
        static let pivot = "pivot"
    }
    static let requestAuthToken = "auth_token"
    
    static let commandReceiveSocketData = 1000
    static let commandReceiveGlobalData = 1001
    static let commandRoomChanged = 1002
}
