//
//  First.swift
//  SotatekCore
//
//  Created by Loc Nguyen on 9/16/16.
//  Copyright © 2016 Thanh Tran. All rights reserved.
//

import Foundation
import RxSwift

extension Observable {
    public static func first(_ a: Observable, _ b: Observable) -> Observable {
        return a.single().catchError({error in
            return b
        })

    }
}
