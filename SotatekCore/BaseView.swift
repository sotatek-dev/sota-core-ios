//
//  BaseView.swift
//  SotatekCore
//
//  Created by Thanh Tran on 10/4/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    open func viewDidAppear() {
        
    }
    
    open func viewWillDisappear() {
        
    }
    
    func getNotifierName() -> String {
        return ""
    }
    
    func getNotifider() -> Notifier {
        return Notifier.instance(getNotifierName())
    }
    
    func addObserver(_ observer: Observer) {
        getNotifider().addObserver(observer)
    }
    
    func removeObserver(_ observer: Observer) {
        getNotifider().removeObserver(observer)
    }
    
    func notifyObservers(_ command: String, data: AnyObject? = nil) {
        getNotifider().notifyObservers(command, data: data)
    }
    
    func notifyObservers(_ command: Command, data: AnyObject? = nil) {
        getNotifider().notifyObservers(command.rawValue, data: data)
    }
}
