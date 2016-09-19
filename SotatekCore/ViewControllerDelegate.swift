//
//  ViewControllerDelegate.swift
//  SotatekCore
//
//  Created by Loc Nguyen on 9/14/16.
//  Copyright © 2016 Thanh Tran. All rights reserved.
//

import Foundation
import UIKit

protocol ViewControllerDelegate {
    func viewControllerDidDismiss(_ sender: UIViewController, _ data: [String: AnyObject])
}
