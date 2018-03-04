//
//  CBCharacteristic+Reactive.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 04/03/2018.
//

import CoreBluetooth
import Foundation
import ReactiveCocoa
import ReactiveSwift
import Result

extension Reactive where Base: CBCharacteristic {

    /// The value of the characteristic.

    public var value: Property<Data?> {
        get {
            guard let value = objc_getAssociatedObject(base, &CBCharacteristic.Associations.value) as? Property<Data?> else {
                let value = Property<Data?>(initial: base.value,
                                            then: producer(forKeyPath: #keyPath(CBCharacteristic.value))
                                                .map { $0 as? Data }
                )

                objc_setAssociatedObject(base,
                                         &CBCharacteristic.Associations.value,
                                         value,
                                         objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

                return value
            }

            return value
        }
    }

    /// A list of the descriptors that have been discovered in this characteristic.

    public var descriptors: Property<Set<CBDescriptor>> {
        guard let descriptors = objc_getAssociatedObject(base, &CBCharacteristic.Associations.descriptors) as? Property<Set<CBDescriptor>> else {
            let descriptors = Property(initial: Set(),
                                           then: producer(forKeyPath: #keyPath(CBCharacteristic.descriptors))
                                            .filterMap { $0 as? [CBDescriptor] }
                                            .map { Set($0) })

            objc_setAssociatedObject(base,
                                     &CBCharacteristic.Associations.descriptors,
                                     descriptors,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            return descriptors

        }
        return descriptors
    }

    /// The properties of the characteristic.

    public var properties: Property<CBCharacteristicProperties> {
        get  {
            guard let properties = objc_getAssociatedObject(base, CBCharacteristic.Associations.properties) as? Property<CBCharacteristicProperties> else {

                let properties = Property<CBCharacteristicProperties>(value: base.properties)

                objc_setAssociatedObject(base,
                                         &CBCharacteristic.Associations.properties,
                                         properties,
                                         objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

                return properties
            }

            return properties
        }
    }

    /// The properties of the characteristic.

    public var isNotifying: Property<Bool> {
        get  {
            guard let isNotifying = objc_getAssociatedObject(base, CBCharacteristic.Associations.isNotifying) as? Property<Bool> else {

                let isNotifying = Property<Bool>(initial: base.isNotifying,
                                                 then: producer(forKeyPath: #keyPath(CBCharacteristic.isNotifying))
                                                    .filterMap { $0 as? Bool }
                )

                objc_setAssociatedObject(base,
                                         &CBCharacteristic.Associations.isNotifying,
                                         isNotifying,
                                         objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

                return isNotifying
            }

            return isNotifying
        }
    }

    /// Retrieves the value of a specified characteristic.

    public func readValue() -> SignalProducer<CBCharacteristic, NSError> {
        return base
            .service
            .peripheral
            .reactive
            .readValue(for: base)
    }

    /// Writes the value of a characteristic.

    public func writeValue(_ data: Data,
                           type: CBCharacteristicWriteType) -> SignalProducer<CBCharacteristic, NSError> {

        return base
            .service
            .peripheral
            .reactive
            .writeValue(data, for: base, type: type)
    }

    /// Sets notifications or indications for the value of a specified characteristic.

    public func setNotifyValue(_ enabled: Bool) -> SignalProducer<CBCharacteristic, NSError> {

        return base
            .service
            .peripheral
            .reactive
            .setNotifyValue(enabled, for: base)
    }

    public var didUpdateNotificationState: Signal<(isNotifying: Bool, error: Error?), NoError> {

        return base
            .service
            .peripheral
            .reactive
            .didUpdateNotificationState
            .filter { $0.characteristic == self.base }
            .map { (isNotifying: $0.characteristic.isNotifying, error: $0.error) }
    }

    public var didWriteValue: Signal<(characteristic: CBCharacteristic, error: Error?), NoError> {

        return base
            .service
            .peripheral
            .reactive
            .didUpdateValueForCharacteristic
            .filter { $0.characteristic == self.base }
    }

    public var didUpdateValue: Signal<(value: Data?, error: Error?), NoError> {

        return base
            .service
            .peripheral
            .reactive
            .didUpdateValueForCharacteristic
            .filter { $0.characteristic == self.base }
            .map { (value: $0.characteristic.value, error: $0.error) }
    }

}
