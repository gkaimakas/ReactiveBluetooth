//
//  CentralManager.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 25/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveCocoa
import ReactiveSwift
import Result

public class CentralManager {
	let central: CBCentralManager
	let delegate: CentralManagerObserver
	let didStopScan: Signal<Void, NoError>
	let discoveredPeripheralCache: SyncDiscoveredPeripheralCache
	let didDiscoverPeripheral: Signal<DiscoveredPeripheral, NoError>

	public let isScanning: Property<Bool>
	public let state: Property<CBManagerState>

	public convenience init(queue: DispatchQueue? = nil,
	     options: Set<InitializationOption>? = nil) {

		let central = CBCentralManager(delegate: nil,
		                                queue: queue,
		                                options: options?.merge())

        self.init(central: central)
	}

    init(central: CBCentralManager) {

        weak var _self: CentralManager!

        self.discoveredPeripheralCache = SyncDiscoveredPeripheralCache()

        self.delegate = CentralManagerObserver()
        self.central = central
        self.central.delegate = self.delegate

        didStopScan = central
            .reactive
            .trigger(for: #selector(CBCentralManager.stopScan))

        isScanning = Property(initial: central.isScanning,
                              then: central
                                .reactive
                                .producer(forKeyPath: #keyPath(CBCentralManager.isScanning))
                                .map { $0 as? Bool }
                                .skipNil()
            )
            .skipRepeats()

        self.state = Property<CBManagerState>(initial: central.state,
                                              then: delegate
                                                .events
                                                .filter { $0.filter(central: central) }
                                                .filter { $0.isDidUpdateStateEvent() }
                                                .map { DidUpdateStateEvent(event: $0) }
                                                .skipNil()
                                                .map { $0.central.state })

        didDiscoverPeripheral = delegate
            .events
            .filter { $0.filter(central: central) }
            .filter { $0.isDidDiscoverEvent() }
            .map { DidDiscoverEvent(event: $0) }
            .skipNil()
            .map { event -> DiscoveredPeripheral in
                let peripheral = Peripheral(peripheral: event.peripheral,
                                            central: _self)

                return DiscoveredPeripheral(peripheral: peripheral,
                                            advertismentData: event.advertismentData,
                                            RSSI: event.RSSI)
        }

        // It updates the local cache with updates coming from `didDiscover(central:, peripheral:, advertismentData:, rssi)`
        // It should be thread safe ()
        discoveredPeripheralCache
            .reactive
            .synchronizeDiscoveredPeripherals <~ didDiscoverPeripheral

        _self = self

    }

	/// Returns known peripherals by their identifiers.
	public func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> SignalProducer<[Peripheral], NoError> {
		return SignalProducer(value: central
			.retrievePeripherals(withIdentifiers: identifiers)
			.map { Peripheral(peripheral: $0,
			                  central: self)
			}
		)
	}

	/// Returns a list of the peripherals (containing any of the specified services) currently
	/// connected to the system.
	public func retrieveConnectedPeripherals(withServices services: [CBUUID]) -> SignalProducer<[Peripheral], NoError> {

		return SignalProducer(value: central
			.retrieveConnectedPeripherals(withServices: services)
			.map { Peripheral(peripheral: $0,
			                  central: self)
			}
		)
	}

	/// Scans for peripherals that are advertising the specified services.
	/// Duplicates are ignored. Please make sure that the central is `poweredOn` before
	/// calling `scanForPeripherals`
	public func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?,
                                   options: Set<ScanOption>? = nil) -> SignalProducer<DiscoveredPeripheral, NoError> {
		let resultProducer = SignalProducer(didDiscoverPeripheral)
		
		let producer = SignalProducer<Void, NoError> {
				self.central.scanForPeripherals(withServices: serviceUUIDs, options: options?.merge())
			}
			.then(resultProducer)
			.take(until: didStopScan)

		return producer
	}


	/// Asks the central manager to stop scanning for peripherals.
	public func stopScan() -> SignalProducer<Void, NoError> {
		let producer = SignalProducer<Void, NoError> {
			self.central.stopScan()
		}

		return producer
	}

	/// Establishes a local connection to a peripheral.
	internal func connect(to peripheral: Peripheral,
	                      options: Set<Peripheral.ConnectionOption>? = nil) -> SignalProducer<Peripheral, NSError> {

		let signal = delegate
			.events
			.filter { $0.filter(central: self.central) }
			.filter { $0.filter(peripheral: peripheral.peripheral) }
			.filter { $0.isDidConnectEvent() }
			.map { DidConnectEvent(event: $0) }
			.skipNil()

		let resultProducer = SignalProducer(signal)
			.take(first: 1)
			.promoteError(NSError.self)
			.flatMap(.latest) { event -> SignalProducer<Peripheral, NSError> in
				if let error = event.error as NSError? {
					return SignalProducer(error: error)
				}

				return SignalProducer(value: peripheral)
			}

		let producer = SignalProducer<Void, NSError> {
				self.central.connect(peripheral.peripheral, options: options?.merge())
			}
			.then(resultProducer)

		return producer
	}

	/// Cancels an active or pending local connection to a peripheral.
	internal func cancelPeripheralConnection(from peripheral: Peripheral) -> SignalProducer<Peripheral, NSError> {

		let signal = delegate
			.events
			.filter { $0.filter(central: self.central) }
			.filter { $0.filter(peripheral: peripheral.peripheral) }
			.filter { $0.isDidDisconnectEvent() }
			.map { DidDisconnectEvent(event: $0) }
			.skipNil()

		let resultProducer = SignalProducer(signal)
			.take(first: 1)
			.promoteError(NSError.self)
			.flatMap(.latest) { event -> SignalProducer<Peripheral, NSError> in
				if let error = event.error as NSError? {
					return SignalProducer(error: error)
				}

				return SignalProducer(value: peripheral)
		}

		let producer = SignalProducer<Void, NSError> {
				self.central.cancelPeripheralConnection(peripheral.peripheral)
			}
			.then(resultProducer)

		return producer
	}
}

// MARK: - Hashable

extension CentralManager: Hashable {
	public var hashValue: Int {
		return central.hashValue
	}

	public static func ==(lhs: CentralManager, rhs: CentralManager) -> Bool {
		return lhs.central == rhs.central
	}
}
