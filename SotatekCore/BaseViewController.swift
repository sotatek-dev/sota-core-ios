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
    var delegate: ViewControllerDelegate?
    var storyboardName: String = "Main"
    
    var views = [UIView]()
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Notifier.instance(Notifier.CONTROLLER_NOTIFIER).addObserver(self)
        for view in views {
            view.viewDidAppear()
        }
    }
    
    override open func viewWillDisappear(_ animated: Bool)  {
        super.viewWillDisappear(animated)
        Notifier.instance(Notifier.CONTROLLER_NOTIFIER).removeObserver(self)
        for view in views {
            view.viewWillDisappear()
        }
    }
    
    open func addView(_ view: UIView) {
        views.append(view)
    }
    
    open func update(_ command: String, data: AnyObject?) {
        
    }
    
    func viewControllerDidDismiss(_ sender: UIViewController, _ data: [String: AnyObject] = [:]) {
        
    }
    
    func showViewController(_ id: String, _ data: [String: AnyObject] = [String: AnyObject](), _ delegate: ViewControllerDelegate? = nil) {
        let vc = CoreUtil.createViewController(storyboardName: storyboardName, id: id) as! BaseViewController
        vc.initData = data
        vc.delegate = delegate
        self.present(vc, animated: true, completion: nil)
    }
    
    func showDialog(_ id: String, _ data: [String: AnyObject] = [String: AnyObject](), _ delegate: ViewControllerDelegate? = nil) {
        let vc = CoreUtil.createViewController(storyboardName: storyboardName, id: id) as! BaseViewController
        vc.initData = data
        vc.delegate = delegate
        self.present(vc, animated: true, completion: nil)
    }
    
    func showRootViewController(_ id: String, _ data: [String: AnyObject] = [String: AnyObject]()) {
        let vc = CoreUtil.createViewController(storyboardName: storyboardName, id: id) as! BaseViewController
        vc.initData = data
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    func dismissViewController(_ data: [String: AnyObject] = [:]) {
        responseData = data
        self.dismiss(animated: true, completion: {});
    }
}
