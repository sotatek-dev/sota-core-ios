//
//  BaseService.swift
//  SotatekCore
//
//  Created by Loc Nguyen on 9/8/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation

open class BaseService {
    var notifier = Notifier.instance(Notifier.SERVICE_NOTIFIER)
    
    func notifyObservers(_ command: String, data: AnyObject? = nil) {
        notifier.notifyObservers(command, data: data)
    }
    
    func addObserver(_ observer: Observer) {
        notifier.addObserver(observer)
    }
    
    func removeObserver(_ observer: Observer) {
        notifier.removeObserver(observer)
    }
}
