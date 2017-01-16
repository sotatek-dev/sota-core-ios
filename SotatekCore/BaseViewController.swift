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
    var notifierNames: Set<String> = []
    let notifierUuid = Util.uuid()
    public var notifierName: String { return String(describing: type(of: self)) + notifierUuid }

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
        if views.count > 0 || controllers.count > 0 {
            addnotifierName(notifierName)
        }
        for channel in notifierNames {
            Notifier.instance(channel).addObserver(self)
        }
        Notifier.viewNotifier.addObserver(self) // listen for events from subviews
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
        for channel in notifierNames {
            Notifier.instance(channel).removeObserver(self)
        }
        Notifier.viewNotifier.removeObserver(self)
        for view in views {
            view.viewWillDisappear()
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
    
    open func removeView(_ view: UIView) {
        views.removeObject(view)
    }

    open func addnotifierNames(_ channels: [String]) {
        for channel in channels {
            notifierNames.insert(channel)
        }
    }

    open func addnotifierName(_ channel: String) {
        notifierNames.insert(channel)
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
    
    func showViewController(_ id: String, data: [String: Any] = [String: Any](), delegate: ViewControllerDelegate? = nil, from: UIViewController? = nil) {
        let vc = Util.createViewController(storyboardName: AppConfig.storyboardName, id: id) as! BaseViewController
        vc.initData = data
        vc.delegate = delegate
        (from ?? self).present(vc, animated: true, completion: nil)
    }
    
    func showDialog(_ id: String, data: [String: Any] = [String: Any](), delegate: ViewControllerDelegate? = nil) {
        let vc = Util.createViewController(storyboardName: AppConfig.storyboardName, id: id) as! BaseViewController
        vc.initData = data
        vc.delegate = DialogDelegate(viewController: self as? BaseViewController, delegate: delegate)
        vc.modalPresentationStyle = .custom
        self.present(vc, animated: true, completion: {
            if let baseViewController = self as? BaseViewController {
                baseViewController.viewWillDisappear(true)
            }
        })
    }
    
    func showRootViewController(_ id: String, data: [String: Any] = [String: Any]()) {
        let vc = Util.createViewController(storyboardName: AppConfig.storyboardName, id: id) as! BaseViewController
        vc.initData = data
        UIApplication.shared.keyWindow?.rootViewController = vc
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
                viewController.viewDidAppear(true)
            }
            if let delegate = delegate {
                delegate.viewControllerDidDismiss?(sender: sender, data: data)
            }
        }
    }
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
