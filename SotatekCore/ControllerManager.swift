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
    var notifierName: String { get }
}


public class AppControllerManager: ControllerManager {
    public static var instance = AppControllerManager()

    private init() {

    }

    public var notifierName: String {
        return "global"
    }
    public func addController(_ controller: BaseController) {}
    public func releaseControllers() {
        // nothing
        // be careful, if use this manager, controller will never be released
    }
}
