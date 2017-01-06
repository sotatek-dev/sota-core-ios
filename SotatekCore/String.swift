//
//  String.swift
//  Nekopost
//
//  Created by An Nguyen on 5/19/16.
//  Copyright © 2016 Sota Tek. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
