//
//  Storage.swift
//  SotatekCore
//
//  Created by Thanh Tran on 5/30/17.
//  Copyright © 2017 SotaTek. All rights reserved.
//

import Foundation

protocol Storage {
    func migrate(fromVersion: Int, toVersion: Int)
}
