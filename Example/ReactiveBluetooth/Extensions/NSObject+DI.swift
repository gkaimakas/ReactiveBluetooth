//
//  NSObject+DI.swift
//  ReactiveBluetooth_Example
//
//  Created by George Kaimakas on 06/03/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import Swinject

extension NSObject {
    public func inject<T>(_ type: T.Type) -> T? {
        guard let entity = (UIApplication.shared.delegate as? AppDelegate)?.container.resolve(type) else {
            fatalError("Could not inject \(type)")
        }
        return entity
    }
}
