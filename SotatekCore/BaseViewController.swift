//
//  BaseViewController.swift
//  SotatekCore
//
//  Created by Thanh Tran on 9/8/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation
import UIKit

open class BaseViewController: UIViewController, ViewControllerDelegate, Observer {
    var initData = [String: Any]()
    var responseData = [String: Any]()
    var delegate: ViewControllerDelegate?
    var viewAppeared = false
    
    var views = [UIView]()
    
    fileprivate var controllers: [BaseController] = []
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !viewAppeared {
            for view in views {
                view.viewWillAppear()
            }
        } else {
            for view in views {
                view.viewWillReappear()
            }
        }
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppear()
    }

    fileprivate func viewDidAppear() {
        Notifier.controllerNoitfier.addObserver(self) // listen for events from controller
        Notifier.viewNotifier.addObserver(self) // listen for events from subviews
        Notifier.globalNotifier.addObserver(self)
        for controller in controllers {
            controller.isPause = false
        }
        if !viewAppeared {
            for view in views {
                view.viewDidAppear()
            }
        } else {
            for view in views {
                view.viewDidReappear()
            }
        }
        viewAppeared = true
    }
    
    override open func viewWillDisappear(_ animated: Bool)  {
        super.viewWillDisappear(animated)
        viewWillDisappear()
    }

    fileprivate func viewWillDisappear() {
        Notifier.controllerNoitfier.removeObserver(self)
        Notifier.viewNotifier.removeObserver(self)
        Notifier.globalNotifier.removeObserver(self)
        for controller in controllers {
            controller.isPause = true
        }
        for view in views {
            view.viewWillDisappear()
        }
    }
    
    open func addView(_ view: UIView) {
        views.append(view)
    }
    
    open func removeView(_ view: UIView) {
        views.removeObject(view)
    }

    open func onTouch(_ gesture: UIGestureRecognizer) -> Bool {
        return GestureUtil.processGesture(gesture, views: views)
    }

    func showViewController(_ id: String, data: [String: Any] = [String: Any](), delegate: ViewControllerDelegate? = nil, from: UIViewController? = nil) {
        let vc = Util.createViewController(storyboardName: AppConfig.storyboardName, id: id) as! BaseViewController
        vc.initData = data
        vc.delegate = delegate ?? self
        (from ?? self).present(vc, animated: true, completion: nil)
    }

    func showDialog(_ id: String, data: [String: Any] = [String: Any](), delegate: ViewControllerDelegate? = nil) {
        let vc = Util.createViewController(storyboardName: AppConfig.storyboardName, id: id) as! BaseViewController
        vc.initData = data
        vc.delegate = DialogDelegate(viewController: self as? BaseViewController, delegate: delegate ?? self)
        vc.modalPresentationStyle = .custom
        self.present(vc, animated: true, completion: {
            if let baseViewController = self as? BaseViewController {
                baseViewController.viewWillDisappear(true)
            }
        })
    }

    static func showRootViewController(_ id: String, data: [String: Any] = [String: Any]()) {
        let vc = Util.createViewController(storyboardName: AppConfig.storyboardName, id: id) as! BaseViewController
        vc.initData = data
        UIApplication.shared.keyWindow?.set(rootViewController: vc)
    }

    class DialogDelegate: ViewControllerDelegate {
        var delegate: ViewControllerDelegate?
        weak var viewController: BaseViewController?

        init(viewController: BaseViewController?, delegate: ViewControllerDelegate?) {
            self.viewController = viewController
            self.delegate = delegate
        }

        func viewControllerDidDismiss(sender: UIViewController, data: [String: Any]) {
            if let viewController = self.viewController {
                viewController.setNeedsStatusBarAppearanceUpdate()
                viewController.viewDidAppear(true)
            }
            if let delegate = delegate {
                delegate.viewControllerDidDismiss?(sender: sender, data: data)
            }
        }
    }

    func dismissViewController(animated: Bool = true, data: [String: Any] = [:]) {
        responseData = data
        // prevent mem leak
        let delegate = self.delegate
        self.delegate = nil
        self.dismiss(animated: animated, completion: {
            delegate?.viewControllerDidDismiss?(sender: self, data: data)
        })
    }
    
    public func update(_ command: Int, data: Any?) {}

    deinit {
        releaseControllers()
    }
}

extension UIViewController {
}

extension BaseViewController: ControllerManager {
    open func addController(_ controller: BaseController) {
        controllers.append(controller)
    }

    open func releaseControllers() {
        for controller in controllers {
            Notifier.serviceNotifier.removeObserver(controller)
        }
    }
}
