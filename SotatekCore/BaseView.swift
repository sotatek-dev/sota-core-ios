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
        Notifier.viewNotifier.addObserver(self)
    }
    
    open func viewDidReappear(_ data: Any? = nil) {
        Notifier.viewNotifier.addObserver(self)
    }
    
    open func viewWillDisappear() {
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

    func removeAllSubViews() {
        subviews.forEach({
            $0.removeFromSuperview()
        })
    }
}

class BaseView: UIView, ControllerManager {
    var views = [UIView]()
    var notifierNames: Set<String> = []
    private var controllers: [BaseController] = []

    let notifierUuid = Util.uuid()
    var notifierName: String { return String(describing: type(of: self)) + notifierUuid}

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
        super.viewDidAppear(data)
        if views.count > 0 || controllers.count > 0 {
            addnotifierName(notifierName)
        }
        for channel in notifierNames {
            Notifier.instance(channel).addObserver(self)
            print("====================== listen from " + channel)
        }

        for view in views {
            view.viewDidAppear(data)
        }
    }

    open override func viewDidReappear(_ data: Any? = nil) {
        super.viewDidReappear(data)
        for channel in notifierNames {
            Notifier.instance(channel).addObserver(self)
        }
        for view in views {
            view.viewDidReappear(data)
        }
    }

    override open func viewWillDisappear()  {
        super.viewWillDisappear()
        for view in views {
            view.viewWillDisappear()
        }
        for channel in notifierNames {
            Notifier.instance(channel).removeObserver(self)
        }
    }

    open func addView(_ view: UIView) {
        views.append(view)
        addnotifierName(notifierName)
        if let baseView = view as? BaseView {
            baseView.addnotifierName(notifierName)
            baseView.addnotifierNames(Array(notifierNames))
        }
    }

    open func addnotifierNames(_ channels: [String]) {
        for channel in channels {
            notifierNames.insert(channel)
        }
    }

    open func addnotifierName(_ channel: String) {
        notifierNames.insert(channel)
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
