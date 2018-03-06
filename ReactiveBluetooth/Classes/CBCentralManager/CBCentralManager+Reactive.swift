//
//  CBCentralManager+Reactive.swift
//  FBSnapshotTestCase
//
//  Created by George Kaimakas on 01/03/2018.
//

import CoreBluetooth
import Foundation
import ReactiveCocoa
import ReactiveSwift
import Result

extension Reactive where Base: CBCentralManager {
    public var isScanning: Property<Bool> {
        guard let isScanning = objc_getAssociatedObject(base, &CBCentralManager.Associations.isScanning) as? Property<Bool> else {
            let isScanning = Property(initial: base.isScanning,
                                      then: producer(forKeyPath: #keyPath(CBCentralManager.isScanning))
                                        .filterMap { $0 as? Bool }
                )
                .skipRepeats()

            objc_setAssociatedObject(base,
                                     &CBCentralManager.Associations.isScanning,
                                     isScanning,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            return isScanning
        }

        return isScanning
    }

    public var state: Property<CBManagerState> {
        guard let state = objc_getAssociatedObject(base, &CBCentralManager.Associations.state) as? Property<CBManagerState> else {
            let state = Property(initial: base.state,
                                 then: producer(forKeyPath: #keyPath(CBCentralManager.state))
                                    .filterMap { $0 as? CBManagerState }
                )
                .skipRepeats()

            objc_setAssociatedObject(base,
                                     &CBCentralManager.Associations.state,
                                     state,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            return state

        }
        return state
    }

    /// Returns known peripherals by their identifiers.
    public func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> SignalProducer<[CBPeripheral], NoError> {
        return SignalProducer(value: base.retrievePeripherals(withIdentifiers: identifiers))
            .on(value: { list in
                list.forEach { $0.centralManager = self.base }
            })
    }

    /// Returns a list of the peripherals (containing any of the specified services) currently
    /// connected to the system.
    public func retrieveConnectedPeripherals(withServices services: [CBUUID]) -> SignalProducer<[CBPeripheral], NoError> {
        return SignalProducer(value: base.retrieveConnectedPeripherals(withServices: services))
            .on(value: { list in
                list.forEach { $0.centralManager = self.base }
            })
    }

    /// Scans for peripherals that are advertising the specified services.
    /// Duplicates are ignored. Please make sure that the central is `poweredOn` before
    /// calling `scanForPeripherals`
    /// When the producer gets disposed the scan stops
    public func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?,
                                   options: Set<CBCentralManager.ScanOption>? = nil)
        -> SignalProducer<(peripheral: CBPeripheral, advertismentData: Set<CBPeripheral.AdvertismentData>, RSSI: NSNumber), NoError> {

        let resultProducer = SignalProducer(didDiscoverPeripheral)

        return SignalProducer<Void, NoError> { observer, disposable in
                self.base.scanForPeripherals(withServices: serviceUUIDs, options: options?.merge())

                disposable.observeEnded {
                    self.base.stopScan()
                }

                observer.sendCompleted()
            }
            .take(until: didStopScan)
            .then(resultProducer)
            .on(value: { bundle in
                bundle.peripheral.centralManager = self.base
            })
    }

    /// Asks the central manager to stop scanning for peripherals.
    public func stopScan() -> SignalProducer<Void, NoError> {
        return SignalProducer<Void, NoError> { observer, disposable in
            self.base.stopScan()
            observer.send(value: ())
            observer.sendCompleted()

        }
    }

    /// Establishes a local connection to a peripheral.
    public func connect(_ peripheral: CBPeripheral,
                          options: Set<CBPeripheral.ConnectionOption>? = nil) -> SignalProducer<CBPeripheral, NSError> {

        let resultProducer = SignalProducer<CBCentralManager.DelegateEvent, NoError>(delegate.event)
            .filter { $0.filter(central: self.base) }
            .filterMap { $0.didConnect }
            .filter { $0.peripheral == peripheral }
            .take(first: 1)
            .flatMap(.latest) { event -> SignalProducer<CBPeripheral, NSError> in
                if let error = event.error as NSError? {
                    return SignalProducer<CBPeripheral, NSError>(error: error)
                }

                return  SignalProducer<CBPeripheral, NSError>(value: event.peripheral)
            }

        return SignalProducer<Void, NSError> { (observer, _) in
                self.base.connect(peripheral, options: options?.merge())
                observer.sendCompleted()
            }
            .then(resultProducer)
    }

    /// Cancels an active or pending local connection to a peripheral.
    public func cancelPeripheralConnection(_ peripheral: CBPeripheral) -> SignalProducer<CBPeripheral, NSError> {

        let resultProducer = SignalProducer<CBCentralManager.DelegateEvent, NoError>(delegate.event)
            .filter { $0.filter(central: self.base) }
            .filterMap { $0.didDisconnect }
            .filter { $0.peripheral == peripheral }
            .take(first: 1)
            .flatMap(.latest) { event -> SignalProducer<CBPeripheral, NSError> in
                if let error = event.error as NSError? {
                    return SignalProducer<CBPeripheral, NSError>(error: error)
                }

                return  SignalProducer<CBPeripheral, NSError>(value: event.peripheral)
        }
        return SignalProducer<Void, NSError> { (observer, _) in
                self.base.cancelPeripheralConnection(peripheral)
                observer.sendCompleted()
            }
            .then(resultProducer)
    }
}

extension Reactive where Base: CBCentralManager {
    internal var delegate: CBCentralManager.ReactiveDelegate {
        get {
            guard let delegate = objc_getAssociatedObject(base, &CBCentralManager.Associations.delegate) as? CBCentralManager.ReactiveDelegate else {

                let delegate = CBCentralManager.ReactiveDelegate()

                objc_setAssociatedObject(base,
                                         &CBCentralManager.Associations.delegate,
                                         delegate,
                                         objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                base.delegate = delegate
                return delegate
            }

            return delegate
        }
    }

    internal var didStopScan: Signal<Void, NoError> {
        get {
            guard let signal = objc_getAssociatedObject(base, CBCentralManager.Associations.didStopScan) as? Signal<Void, NoError> else {
                let didStopScan = trigger(for: #selector(CBCentralManager.stopScan))

                objc_setAssociatedObject(base,
                                         &CBCentralManager.Associations.didStopScan,
                                         didStopScan,
                                         objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

                return didStopScan
            }

            return signal
        }
    }
}

extension Reactive where Base: CBCentralManager {
    public var didUpdateState: Signal<CBManagerState, NoError> {
        return delegate
            .event
            .filter { $0.filter(central: self.base) }
            .filterMap { $0.didUpdateState?.state }
    }

    public var willRestoreState: Signal<[String: Any], NoError> {
        return delegate
            .event
            .filter { $0.filter(central: self.base) }
            .filterMap { $0.willRestoreState }
    }

    public var didDiscoverPeripheral: Signal<(peripheral: CBPeripheral, advertismentData: Set<CBPeripheral.AdvertismentData>, RSSI: NSNumber), NoError> {
        return delegate
            .event
            .filter { $0.filter(central: self.base) }
            .filterMap { $0.didDiscoverPeripheral }
    }

    public var didConnectPeriperhal: Signal<(peripheral: CBPeripheral, error: Error?), NoError> {
        return delegate
            .event
            .filter { $0.filter(central: self.base) }
            .filterMap { $0.didConnect }
    }
    
    public var didDisconnectPeripheral: Signal<(peripheral: CBPeripheral, error: Error?), NoError> {
        return delegate
            .event
            .filter { $0.filter(central: self.base) }
            .filterMap { $0.didDisconnect }
    }
}
