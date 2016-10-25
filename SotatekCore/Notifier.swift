//
//  Notifier.swift
//  SotatekCore
//
//  Created by Thanh Tran on 9/8/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation

open class Notifier {
    //open static let SERVICE_NOTIFIER = "service"
    //open static let CONTROLLER_NOTIFIER = "controller"
    
    open static let serviceNotifier = Notifier.instance("controller")
    open static let controllerNoitfier = Notifier.instance("service")
    open static let socketNoitfier = Notifier.instance("socket")
    open static let repositoryNotifier = Notifier.instance("repository")
    
    fileprivate static var instances = [String: Notifier]()
    open static func instance(_ name: String) -> Notifier {
        var instance = instances[name]
        if instance == nil {
            instance = Notifier()
            instances[name] = instance
        }
        return instance!
    }
    
    var observers = [Observer]()
    
    init() {
    }
    
    func addObserver(_ observer: Observer) {
        if observers.index(where: {$0 === observer}) == nil {
            observers.append(observer)
        }
    }
    
    func removeObserver(_ observer: Observer) {
        if let index = observers.index(where: {$0 === observer}) {
            observers.remove(at: index)
        }
    }
    
    func notifyObservers(_ command: String, data: AnyObject? = nil) {
        for observer in observers {
            observer.update(command, data: data)
        }
    }
}
