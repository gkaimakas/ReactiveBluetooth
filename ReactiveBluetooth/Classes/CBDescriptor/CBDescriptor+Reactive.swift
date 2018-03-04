//
//  CBDescriptor+Reactive.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 04/03/2018.
//

import CoreBluetooth
import Foundation
import ReactiveCocoa
import ReactiveSwift
import Result

extension Reactive where Base: CBDescriptor {

    /// The value of the descriptor.

    public var value: Property<Any?> {
        get {
            guard let value = objc_getAssociatedObject(base, &CBDescriptor.Associations.value) as? Property<Any?> else {

                let value = Property<Any?>(initial: base.value,
                                            then: producer(forKeyPath: #keyPath(CBCharacteristic.value)))

                objc_setAssociatedObject(base,
                                         &CBDescriptor.Associations.value,
                                         value,
                                         objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

                return value
            }

            return value
        }
    }
}
