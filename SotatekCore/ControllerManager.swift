//
//  ControllerManager.swift
//  Exclusiv
//
//  Created by Thanh Tran on 12/16/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation

public protocol ControllerManager {
    func addController(_ controller: BaseController)
    func releaseControllers()
}
