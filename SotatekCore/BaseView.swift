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
    open func viewWillAppear() {

    }

    open func viewWillReappear() {
        
    }

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

    func autoResize() {
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight,.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
    }
}

class BaseView: UIView, ControllerManager {
    var views = [UIView]()
    private var controllers: [BaseController] = []

    open override func viewWillAppear() {
        super.viewWillAppear()
        for view in views {
            view.viewWillAppear()
        }
    }

    open override func viewWillReappear() {
        super.viewWillReappear()
        for view in views {
            view.viewWillReappear()
        }
    }

    open override func viewDidAppear(_ data: Any? = nil) {
        for controller in controllers {
            controller.isPause = false
        }
        super.viewDidAppear(data)
        for view in views {
            view.viewDidAppear(data)
        }
    }

    open override func viewDidReappear(_ data: Any? = nil) {
        for controller in controllers {
            controller.isPause = false
        }
        super.viewDidReappear(data)
        for view in views {
            view.viewDidReappear(data)
        }
    }

    override open func viewWillDisappear()  {
        super.viewWillDisappear()
        for view in views {
            view.viewWillDisappear()
        }

        for controller in controllers {
            controller.isPause = true
        }
    }

    open func addView(_ view: UIView) {
        views.append(view)
    }

    open func onTouch(_ gesture: UIGestureRecognizer) -> Bool {
        return GestureUtil.processGesture(gesture, views: views)
    }

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
