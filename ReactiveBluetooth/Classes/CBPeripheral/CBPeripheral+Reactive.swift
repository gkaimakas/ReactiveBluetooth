//
//  CBPeripheral+Reactive.swift
//  FBSnapshotTestCase
//
//  Created by George Kaimakas on 02/03/2018.
//

import CoreBluetooth
import Foundation
import ReactiveCocoa
import ReactiveSwift
import Result

extension Reactive where Base: CBPeripheral {
    public var name: Property<String?> {
        guard let name = objc_getAssociatedObject(base, &CBPeripheral.Associations.name) as? Property<String?> else {
            let name = Property(initial: base.name,
                                then: producer(forKeyPath: #keyPath(CBPeripheral.name))
                                    .filterMap { $0 as? String? })

            objc_setAssociatedObject(base,
                                     &CBPeripheral.Associations.name,
                                     name,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            return name

        }
        return name
    }

    public var identifier: Property<UUID> {
        guard let identifier = objc_getAssociatedObject(base, &CBPeripheral.Associations.identifier) as? Property<UUID> else {
            let identifier = Property(value: base.identifier)

            objc_setAssociatedObject(base,
                                     &CBPeripheral.Associations.identifier,
                                     name,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            return identifier

        }
        return identifier
    }

    public var state: Property<CBPeripheralState> {
        guard let state = objc_getAssociatedObject(base, &CBPeripheral.Associations.state) as? Property<CBPeripheralState> else {
            let state = Property<CBPeripheralState>(initial: base.state,
                                                    then: producer(forKeyPath: #keyPath(CBPeripheral.state))
                                                        .filterMap({ $0 as? Int })
                                                        .filterMap({ CBPeripheralState(rawValue: $0)})
            )

            objc_setAssociatedObject(base,
                                     &CBPeripheral.Associations.state,
                                     state,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            return state

        }
        return state
    }

    public var services: Property<Set<CBService>> {
        guard let services = objc_getAssociatedObject(base, &CBPeripheral.Associations.services) as? Property<Set<CBService>> else {
            let services = Property(initial: Set(),
                                    then: producer(forKeyPath: #keyPath(CBPeripheral.services))
                                        .filterMap { $0 as? [CBService] }
                                        .map { Set($0) })

            objc_setAssociatedObject(base,
                                     &CBPeripheral.Associations.services,
                                     services,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            return services

        }
        return services
    }

    public var discovered: CBPeripheral.Discovered {
        get {
            guard let discovered = objc_getAssociatedObject(base, &CBPeripheral.Associations.discovered) as? CBPeripheral.Discovered else {

                let discovered = CBPeripheral.Discovered()

                objc_setAssociatedObject(base,
                                         &CBPeripheral.Associations.discovered,
                                         discovered,
                                         objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

                return discovered
            }

            return discovered
        }
    }

    /// Establishes a local connection to this peripheral
    
    public func connect(options: Set<CBPeripheral.ConnectionOption>? = nil) -> SignalProducer<CBPeripheral, NSError> {
        guard let central = base.centralManager else {
            fatalError("Can't use `connect(options:)` on a CBPeripheral that was not retrieved through CBCentralManager.reactive related methods")
        }

        return central
            .reactive
            .connect(base, options: options)
    }

    /// Cancels the connection to this peripheral

    public func cancelPeripheralConnection() -> SignalProducer<CBPeripheral, NSError> {
        guard let central = base.centralManager else {
            fatalError("Can't use `cancelPeripheralConnection` on a CBPeripheral that was not retrieved through CBCentralManager.reactive related methods")
        }

        return central
            .reactive
            .cancelPeripheralConnection(self.base)
    }

    /// Discovers the specified services of the peripheral.

    public func discoverServices(_ serviceUUIDs: [CBUUID]?) -> SignalProducer<CBPeripheral, NSError> {
        let resultProducer = SignalProducer(didDiscoverServices)
            .take(first: 1)
            .flatMap(.latest) { (peripheral, error) -> SignalProducer<CBPeripheral, NSError> in
                if let error = error as NSError? {
                    return SignalProducer<CBPeripheral, NSError>(error: error)
                }

                return SignalProducer<CBPeripheral, NSError>(value: peripheral)
            }

        return SignalProducer<Void, NoError>{ (observer, _) in
                self.base.discoverServices(serviceUUIDs)
                observer.sendCompleted()
            }
            .then(resultProducer)
    }

    /// Discovers the specified included services of a service.

    public func discoverIncludedServices(_ includedServiceUUIDs: [CBUUID]?, for service: CBService) -> SignalProducer<CBService, NSError> {
        let resultProducer = SignalProducer(didDiscoverIncludedServices)
            .filter { $0.service == service }
            .take(first: 1)
            .flatMap(.latest) { (service, error) -> SignalProducer<CBService, NSError> in
                if let error = error as NSError? {
                    return SignalProducer<CBService, NSError>(error: error)
                }

                return SignalProducer<CBService, NSError>(value: service)
            }

        return SignalProducer<Void, NoError>{ (observer, _) in
                self.base.discoverIncludedServices(includedServiceUUIDs, for: service)
                observer.sendCompleted()
            }
            .then(resultProducer)
    }

    /// Discovers the specified characteristics of a service.

    public func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService) -> SignalProducer<CBService, NSError> {
        let resultProducer = SignalProducer(didDiscoverCharacteristics)
            .filter { $0.service == service }
            .take(first: 1)
            .flatMap(.latest) { (service, error) -> SignalProducer<CBService, NSError> in
                if let error = error as NSError? {
                    return SignalProducer<CBService, NSError>(error: error)
                }

                return SignalProducer<CBService, NSError>(value: service)
            }

        return SignalProducer<Void, NoError>{ (observer, _) in
                self.base.discoverCharacteristics(characteristicUUIDs, for: service)
                observer.sendCompleted()
            }
            .then(resultProducer)
    }

    /// Discovers the descriptors of a characteristic.

    public func discoverDescriptors(for characteristic: CBCharacteristic) -> SignalProducer<CBCharacteristic, NSError> {
        let resultProducer = SignalProducer(didDiscoverDescriptors)
            .filter { $0.characteristic == characteristic }
            .take(first: 1)
            .flatMap(.latest) { (characteristic, error) -> SignalProducer<CBCharacteristic, NSError> in
                if let error = error as NSError? {
                    return SignalProducer<CBCharacteristic, NSError>(error: error)
                }

                return SignalProducer<CBCharacteristic, NSError>(value: characteristic)
            }

        return SignalProducer<Void, NoError>{ (observer, _) in
                self.base.discoverDescriptors(for: characteristic)
                observer.sendCompleted()
            }
            .then(resultProducer)
    }

    /// Retrieves the value of a specified characteristic.

    public func readValue(for characteristic: CBCharacteristic) -> SignalProducer<CBCharacteristic, NSError> {
        let resultProducer = SignalProducer(didUpdateValueForCharacteristic)
            .filter { $0.characteristic == characteristic }
            .take(first: 1)
            .flatMap(.latest) { (characteristic, error) -> SignalProducer<CBCharacteristic, NSError> in
                if let error = error as NSError? {
                    return SignalProducer<CBCharacteristic, NSError>(error: error)
                }

                return SignalProducer<CBCharacteristic, NSError>(value: characteristic)
            }

        return SignalProducer<Void, NoError>{ (observer, _) in
                self.base.readValue(for: characteristic)
                observer.sendCompleted()
            }
            .then(resultProducer)
    }

    /// Retrieves the value of a specified characteristic descriptor.

    public func readValue(for descriptor: CBDescriptor) -> SignalProducer<CBDescriptor, NSError> {
        let resultProducer = SignalProducer(didUpdateValueForDescriptor)
            .filter { $0.descriptor == descriptor }
            .take(first: 1)
            .flatMap(.latest) { (descriptor, error) -> SignalProducer<CBDescriptor, NSError> in
                if let error = error as NSError? {
                    return SignalProducer<CBDescriptor, NSError>(error: error)
                }

                return SignalProducer<CBDescriptor, NSError>(value: descriptor)
        }

        return SignalProducer<Void, NoError>{ (observer, _) in
                self.base.readValue(for: descriptor)
                observer.sendCompleted()
            }
            .then(resultProducer)
    }

    /// Writes the value of a characteristic.

    public func writeValue(_ data: Data,
                           for characteristic: CBCharacteristic,
                           type: CBCharacteristicWriteType) -> SignalProducer<CBCharacteristic, NSError> {

        let resultProducer = SignalProducer(didWriteValueForCharacteristic)
            .filter { $0.characteristic == characteristic }
            .take(first: 1)
            .flatMap(.latest) { (characteristic, error) -> SignalProducer<CBCharacteristic, NSError> in
                if let error = error as NSError? {
                    return SignalProducer<CBCharacteristic, NSError>(error: error)
                }

                return SignalProducer<CBCharacteristic, NSError>(value: characteristic)
        }

        let producer = SignalProducer<Void, NoError>{ (observer, _) in
            self.base.writeValue(data, for: characteristic, type: type)
            observer.sendCompleted()
        }

        switch type {
        case .withoutResponse:
            return producer
                .then(SignalProducer<CBCharacteristic, NSError>(value: characteristic))

        case .withResponse:
            return producer
                .then(resultProducer)
        }
    }

    /// Writes the value of a characteristic descriptor.

    public func writeValue(_ data: Data,
                           for descriptor: CBDescriptor) -> SignalProducer<CBDescriptor, NSError> {
        let resultProducer = SignalProducer(didWriteValueForDescriptor)
            .filter { $0.descriptor == descriptor }
            .take(first: 1)
            .flatMap(.latest) { (descriptor, error) -> SignalProducer<CBDescriptor, NSError> in
                if let error = error as NSError? {
                    return SignalProducer<CBDescriptor, NSError>(error: error)
                }

                return SignalProducer<CBDescriptor, NSError>(value: descriptor)
        }

        return SignalProducer<Void, NoError>{ (observer, _) in
                self.base.writeValue(data, for: descriptor)
                observer.sendCompleted()
            }
            .then(resultProducer)
    }

    /// Sets notifications or indications for the value of a specified characteristic.

    public func setNotifyValue(_ enabled: Bool,
                               for characteristic: CBCharacteristic) -> SignalProducer<CBCharacteristic, NSError> {

        let resultProducer = SignalProducer(didUpdateNotificationState)
            .filter { $0.characteristic == characteristic }
            .take(first: 1)
            .flatMap(.latest) { (characteristic, error) -> SignalProducer<CBCharacteristic, NSError> in
                if let error = error as NSError? {
                    return SignalProducer<CBCharacteristic, NSError>(error: error)
                }

                return SignalProducer<CBCharacteristic, NSError>(value: characteristic)
        }

        return SignalProducer<Void, NoError>{ (observer, _) in
                self.base.setNotifyValue(enabled, for: characteristic)
                observer.sendCompleted()
            }
            .then(resultProducer)
    }

    /// Retrieves the current RSSI value for the peripheral while it is connected to the central manager.

    public func readRSSI() -> SignalProducer<NSNumber, NSError> {
        let resultProducer = SignalProducer(didReadRSSI)
            .take(first: 1)
            .flatMap(.latest) { (RSSI, error) -> SignalProducer<NSNumber, NSError> in
                if let error = error as NSError? {
                    return SignalProducer<NSNumber, NSError>(error: error)
                }

                return SignalProducer<NSNumber, NSError>(value: RSSI)
        }

        return SignalProducer<Void, NoError>{ (observer, _) in
                self.base.readRSSI()
                observer.sendCompleted()
            }
            .then(resultProducer)
    }
}

extension Reactive where Base: CBPeripheral {
    internal var delegate: CBPeripheral.ReactiveDelegate {
        get {
            guard let delegate = objc_getAssociatedObject(base, &CBPeripheral.Associations.delegate) as? CBPeripheral.ReactiveDelegate else {

                let delegate = CBPeripheral.ReactiveDelegate()

                objc_setAssociatedObject(base,
                                         &CBPeripheral.Associations.delegate,
                                         delegate,
                                         objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

                base.delegate = delegate
                return delegate
            }

            return delegate
        }
    }
}

extension Reactive where Base: CBPeripheral {
    public var didUpdateName: Signal<CBPeripheral, NoError> {
        return delegate
            .event
            .filterMap { $0.didUpdateName }
        
    }

    public var didReadRSSI: Signal<(RSSI: NSNumber, error: Error?), NoError> {
        return delegate
            .event
            .filterMap { $0.didReadRSSI }
    }

    public var didDiscoverServices: Signal<(peripheral: CBPeripheral, error: Error?), NoError> {
        return delegate
            .event
            .filterMap { $0.didDiscoverServices }
    }

    public var didDiscoverIncludedServices: Signal<(service: CBService, error: Error?), NoError> {
        return delegate
            .event
            .filterMap { $0.didDiscoverIncludedServices }
    }
    
    public var didDiscoverCharacteristics: Signal<(service: CBService, error: Error?), NoError> {
        return delegate
            .event
            .filterMap { $0.didDiscoverCharacteristics }
    }

    public var didDiscoverDescriptors: Signal<(characteristic: CBCharacteristic, error: Error?), NoError> {
        return delegate
            .event
            .filterMap { $0.didDiscoverDescriptors }
    }

    public var didUpdateNotificationState: Signal<(characteristic: CBCharacteristic, error: Error?), NoError> {
        return delegate
            .event
            .filterMap { $0.didUpdateNotificationState }
    }

    public var didWriteValueForCharacteristic: Signal<(characteristic: CBCharacteristic, error: Error?), NoError> {
        return delegate
            .event
            .filterMap { $0.didWriteValueForCharacteristic }
    }

    public var didWriteValueForDescriptor: Signal<(descriptor: CBDescriptor, error: Error?), NoError> {
        return delegate
            .event
            .filterMap { $0.didWriteValueForDescriptor }
    }

    public var didUpdateValueForCharacteristic: Signal<(characteristic: CBCharacteristic, error: Error?), NoError> {
        return delegate
            .event
            .filterMap { $0.didUpdateValueForCharacteristic }
    }

    public var didUpdateValueForDescriptor: Signal<(descriptor: CBDescriptor, error: Error?), NoError> {
        return delegate
            .event
            .filterMap { $0.didUpdateValueForDescriptor }
    }
}
