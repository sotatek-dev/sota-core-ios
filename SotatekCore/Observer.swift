//
//  Observer.swift
//  SotatekCore
//
//  Created by Thanh Tran on 9/8/16.
//  Copyright © 2016 SotaTek. All rights reserved.
//

import Foundation

public protocol Observer: class {
    func update(_ command: String, data: AnyObject?)
    func update(_ command: Command, data: AnyObject?)
    func addObserver(_ observer: Observer)
    func removeObserver(_ observer: Observer)
}

extension Observer {
    public func update(_ command: String, data: AnyObject?) {
        DispatchQueue.main.async {
            self.update(Command(rawValue: command)!, data: data)
        }
    }
    
    public func update(_ command: Command, data: AnyObject?){}
    
    public func addObserver(_ observer: Observer) {}
    public func removeObserver(_ observer: Observer) {}
}
