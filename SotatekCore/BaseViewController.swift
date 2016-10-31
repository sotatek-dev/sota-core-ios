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
    weak var delegate: ViewControllerDelegate?
    
    var views = [UIView]()
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Notifier.controllerNoitfier.addObserver(self)
        for view in views {
            view.addObserver(self)
            view.viewDidAppear()
        }
    }
    
    override open func viewWillDisappear(_ animated: Bool)  {
        super.viewWillDisappear(animated)
        Notifier.controllerNoitfier.removeObserver(self)
        for view in views {
            view.viewWillDisappear()
            view.removeObserver(self)
        }
    }
    
    open func addView(_ view: UIView) {
        views.append(view)
    }
    
    func dismissViewController(data: [String: Any] = [:]) {
        responseData = data
        self.dismiss(animated: true, completion: {
            [unowned self] in
            self.delegate?.viewControllerDidDismiss?(sender: self, data: data)
            })
    }
    
    public func update(_ command: Int, data: AnyObject?) {}
}

extension UIViewController {
    
    func showViewController(_ id: String, data: [String: Any] = [String: Any](), delegate: ViewControllerDelegate? = nil) {
        let vc = Util.createViewController(storyboardName: AppConfig.storyboardName, id: id) as! BaseViewController
        vc.initData = data
        vc.delegate = delegate
        self.present(vc, animated: true, completion: nil)
    }
    
    func showDialog(_ id: String, data: [String: Any] = [String: Any](), delegate: ViewControllerDelegate? = nil) {
        let vc = Util.createViewController(storyboardName: AppConfig.storyboardName, id: id) as! BaseViewController
        vc.initData = data
        vc.delegate = delegate
        self.present(vc, animated: true, completion: nil)
    }
    
    func showRootViewController(_ id: String, data: [String: Any] = [String: Any]()) {
        let vc = Util.createViewController(storyboardName: AppConfig.storyboardName, id: id) as! BaseViewController
        vc.initData = data
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
}
