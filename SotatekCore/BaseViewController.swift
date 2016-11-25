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
    var viewAppeared = false
    
    var views = [UIView]()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Notifier.controllerNoitfier.addObserver(self) // listen for events from controller
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
        Notifier.controllerNoitfier.removeObserver(self)
        Notifier.viewNotifier.removeObserver(self)
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
    
    func dismissViewController(data: [String: Any] = [:]) {
        responseData = data
        self.dismiss(animated: true, completion: {
            [unowned self] in
            self.delegate?.viewControllerDidDismiss?(sender: self, data: data)
            })
    }
    
    public func update(_ command: Int, data: Any?) {}
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
