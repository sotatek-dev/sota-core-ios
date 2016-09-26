//
//  ViewControllerDelegate.swift
//  SotatekCore
//
//  Created by Thanh Tran on 9/14/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation
import UIKit

protocol ViewControllerDelegate {
    func viewControllerDidDismiss(_ sender: UIViewController, _ data: [String: AnyObject])
}
