//
//  BaseController.swift
//  SotatekCore
//
//  Created by Thanh Tran on 9/8/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation

open class BaseController: Observer {
    private(set) var notifier: Notifier
    
    init(manager: ControllerManager) {
        self.notifier = Notifier.instance(manager.notifierName)
        print("======================+++++++" + manager.notifierName)
        Notifier.serviceNotifier.addObserver(self)
        manager.addController(self)
    }
    
    func notifyObservers(_ command: Int, data: Any? = nil) {
        notifier.notifyObservers(command, data: data)
    }
    
    public func addObserver(_ observer: Observer) {
        notifier.addObserver(observer)
    }
    
    public func removeObserver(_ observer: Observer) {
        notifier.removeObserver(observer)
    }
    
    public func update(_ command: Int, data: Any?) {}
    
    func initialize() {
        
    }
}
