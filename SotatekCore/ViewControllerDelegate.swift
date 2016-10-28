//
//  ViewControllerDelegate.swift
//  SotatekCore
//
//  Created by Thanh Tran on 9/14/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation
import UIKit

@objc protocol ViewControllerDelegate {
    @objc optional func viewControllerDidDismiss(sender: UIViewController, data: [String: Any])
}
