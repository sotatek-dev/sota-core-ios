//
//  BaseViewController.swift
//  SotatekCore
//
//  Created by Loc Nguyen on 9/8/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation
import UIKit

public class BaseViewController: UIViewController, ViewControllerDelegate, Observer {
    var initData = [String: AnyObject]()
    var responseData = [String: AnyObject]()
    var delegate: ViewControllerDelegate?
    
    public func update(command: String, data: AnyObject?) {
        
    }
    
    func viewControllerDidDismiss(sender: UIViewController, _ data: [String: AnyObject] = [:]) {
        
    }
    
    func showViewController(id: String, _ data: [String: AnyObject] = [String: AnyObject](), _ delegate: ViewControllerDelegate? = nil) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(id) as! BaseViewController
        vc.initData = data
        vc.delegate = delegate
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func showDialog(id: String, _ data: [String: AnyObject] = [String: AnyObject](), _ delegate: ViewControllerDelegate? = nil) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(id) as! BaseViewController
        vc.initData = data
        vc.delegate = delegate
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func showRootViewController(id: String, _ data: [String: AnyObject] = [String: AnyObject]()) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(id) as! BaseViewController
        vc.initData = data
        UIApplication.sharedApplication().keyWindow?.rootViewController = vc
    }
    
    func dismissViewController(data: [String: AnyObject] = [:]) {
        responseData = data
        self.dismissViewControllerAnimated(true, completion: {});
    }
}