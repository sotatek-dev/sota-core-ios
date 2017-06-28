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
        Notifier.globalNotifier.addObserver(self)
    }
    
    open func viewDidReappear(_ data: Any? = nil) {
        Notifier.controllerNoitfier.addObserver(self)
        Notifier.viewNotifier.addObserver(self)
        Notifier.globalNotifier.addObserver(self)
    }
    
    open func viewWillDisappear() {
        Notifier.controllerNoitfier.removeObserver(self)
        Notifier.viewNotifier.removeObserver(self)
        Notifier.globalNotifier.removeObserver(self)
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
    
    func forceConstraintToSuperView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Set constraint to self
        let top = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: self.superview, attribute: .top, multiplier: 1, constant: 0)
        let leading = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: self.superview, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: self.superview, attribute: .trailing, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: self.superview, attribute: .bottom, multiplier: 1, constant: 0)
        
        self.superview?.addConstraints([top, leading, trailing, bottom])
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
        if views.index(of: view) == nil {
            views.append(view)
        }
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

extension UIWindow {

    /// Fix for http://stackoverflow.com/a/27153956/849645
    func set(rootViewController newRootViewController: UIViewController, withTransition transition: CATransition? = nil) {

        let previousViewController = rootViewController

        if let transition = transition {
            // Add the transition
            layer.add(transition, forKey: kCATransition)
        }

        rootViewController = newRootViewController

        // Update status bar appearance using the new view controllers appearance - animate if needed
        if UIView.areAnimationsEnabled {
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                newRootViewController.setNeedsStatusBarAppearanceUpdate()
            }
        } else {
            newRootViewController.setNeedsStatusBarAppearanceUpdate()
        }

        /// The presenting view controllers view doesn't get removed from the window as its currently transistioning and presenting a view controller
        if let transitionViewClass = NSClassFromString("UITransitionView") {
            for subview in subviews where subview.isKind(of: transitionViewClass) {
                subview.removeFromSuperview()
            }
        }
        if let previousViewController = previousViewController {
            // Allow the view controller to be deallocated
            previousViewController.dismiss(animated: false) {
                // Remove the root view in case its still showing
                previousViewController.view.removeFromSuperview()
            }
        }
    }
}
