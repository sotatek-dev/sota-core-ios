//
//  BaseView.swift
//  SotatekCore
//
//  Created by Thanh Tran on 10/4/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation
import UIKit

extension UIView: Observer {
    open func viewDidAppear() {
        
    }
    
    open func viewWillDisappear() {
        
    }
    
    func getNotifierName() -> String {
        return ""
    }
    
    func getNotifier() -> Notifier {
        return Notifier.instance(getNotifierName())
    }
    
    public func addObserver(_ observer: Observer) {
        getNotifier().addObserver(observer)
    }
    
    public func removeObserver(_ observer: Observer) {
        getNotifier().removeObserver(observer)
    }
    
    func notifyObservers(_ command: String, data: AnyObject? = nil) {
        getNotifier().notifyObservers(command, data: data)
    }
    
    func notifyObservers(_ command: Command, data: AnyObject? = nil) {
        getNotifier().notifyObservers(command.rawValue, data: data)
    }
}
