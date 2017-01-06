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
    open func viewDidAppear(_ data: Any? = nil) {
        Notifier.controllerNoitfier.addObserver(self)
        Notifier.viewNotifier.addObserver(self)
    }
    
    open func viewDidReappear(_ data: Any? = nil) {
        Notifier.controllerNoitfier.addObserver(self)
        Notifier.viewNotifier.addObserver(self)
    }
    
    open func viewWillDisappear() {
        Notifier.controllerNoitfier.removeObserver(self)
        Notifier.viewNotifier.removeObserver(self)
    }
    
    func addObserver(_ observer: Observer) {
        Notifier.viewNotifier.addObserver(observer)
    }
    
    func removeObserver(_ observer: Observer) {
        Notifier.viewNotifier.removeObserver(observer)
    }
    
    @nonobjc
    func notifyObservers(_ command: Int, data: AnyObject? = nil) {
        Notifier.viewNotifier.notifyObservers(command, data: data)
    }

    func bringToFront() {
        self.superview?.bringSubview(toFront: self)
    }
}

class BaseView: UIView, ControllerManager {
    private var controllers: [BaseController] = []

    func addController(_ controller: BaseController) {
        controllers.append(controller)
    }

    func releaseControllers() {
        for controller in controllers {
            Notifier.serviceNotifier.removeObserver(controller)
        }
    }

    deinit {
        releaseControllers()
    }
}
