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
    var initData = [String: AnyObject]()
    var responseData = [String: AnyObject]()
    weak var delegate: ViewControllerDelegate?
    var storyboardName: String = "Main"
    
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
    
    func showViewController(_ id: String, data: [String: AnyObject] = [String: AnyObject](), delegate: ViewControllerDelegate? = nil) {
        let vc = Util.createViewController(storyboardName: storyboardName, id: id) as! BaseViewController
        vc.initData = data
        vc.delegate = delegate
        self.present(vc, animated: true, completion: nil)
    }
    
    func showDialog(_ id: String, data: [String: AnyObject] = [String: AnyObject](), delegate: ViewControllerDelegate? = nil) {
        let vc = Util.createViewController(storyboardName: storyboardName, id: id) as! BaseViewController
        vc.initData = data
        vc.delegate = delegate
        self.present(vc, animated: true, completion: nil)
    }
    
    func showRootViewController(_ id: String, data: [String: AnyObject] = [String: AnyObject]()) {
        let vc = Util.createViewController(storyboardName: storyboardName, id: id) as! BaseViewController
        vc.initData = data
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    func dismissViewController(data: [String: AnyObject] = [:]) {
        responseData = data
        self.dismiss(animated: true, completion: {
            [unowned self] in
            self.delegate?.viewControllerDidDismiss?(sender: self, data: data)
        })
    }
    
    public func update(_ command: Int, data: AnyObject?) {}
}
