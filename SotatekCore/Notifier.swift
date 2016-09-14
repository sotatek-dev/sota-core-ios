//
//  Notifier.swift
//  SotatekCore
//
//  Created by Loc Nguyen on 9/8/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation

public class Notifier {
    static let instance = Notifier()
    
    var observers = [Observer]()
    
    init() {
    }
    
    func addObserver(observer: Observer) {
        if observers.indexOf({$0 === observer}) == nil {
            observers.append(observer)
        }
    }
    
    func removeObserver(observer: Observer) {
        if let index = observers.indexOf({$0 === observer}) {
            observers.removeAtIndex(index)
        }
    }
    
    func notifyObservers(command: String, data: AnyObject? = nil) {
        for observer in observers {
            observer.update(command, data: data)
        }
    }
}