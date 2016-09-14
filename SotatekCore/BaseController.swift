//
//  BaseController.swift
//  SotatekCore
//
//  Created by Loc Nguyen on 9/8/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation

public class BaseController: Observer {
    var notifier = Notifier.instance
    
    func notifyObservers(command: String, data: AnyObject? = nil) {
        notifier.notifyObservers(command, data: data)
    }
    
    func addObserver(observer: Observer) {
        notifier.addObserver(observer)
    }
    
    func removeObserver(observer: Observer) {
        notifier.removeObserver(observer)
    }
    public func update(command: String, data: AnyObject?) {
        
    }
}