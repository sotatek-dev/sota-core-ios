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
    
    func getNotifier() -> Notifier {
        return Notifier.instance(getNotifierName())
    }
    
    func addObserver(_ observer: Observer) {
        getNotifier().addObserver(observer)
    }
    
    func removeObserver(_ observer: Observer) {
        getNotifier().removeObserver(observer)
    }
    
    @nonobjc
    func notifyObservers(_ command: Int, data: AnyObject? = nil) {
        getNotifier().notifyObservers(command, data: data)
    }
}
