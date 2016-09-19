//
//  BaseController.swift
//  SotatekCore
//
//  Created by Loc Nguyen on 9/8/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation

open class BaseController: Observer {
    var notifier = Notifier.instance(Notifier.CONTROLLER_NOTIFIER)
    
    init() {
        Notifier.instance(Notifier.SERVICE_NOTIFIER).addObserver(self)
    }
    
    func notifyObservers(_ command: String, data: AnyObject? = nil) {
        notifier.notifyObservers(command, data: data)
    }
    
    func addObserver(_ observer: Observer) {
        notifier.addObserver(observer)
    }
    
    func removeObserver(_ observer: Observer) {
        notifier.removeObserver(observer)
    }
    open func update(_ command: String, data: AnyObject?) {
        
    }
}
