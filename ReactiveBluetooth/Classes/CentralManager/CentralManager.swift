//
//  CentralManager.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 25/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

public class CentralManager {
	let central: CBCentralManager
	let centralDelegate: CentralManagerObserver

	private let didStopScan: Signal<Void, NoError>
	private let didStopScanObserver: Signal<Void, NoError>.Observer

	public let state: Property<CBManagerState>

	public init(queue: DispatchQueue? = nil,
	     options: [String: Any]? = nil) {
		(didStopScan, didStopScanObserver) = Signal.pipe()
		self.centralDelegate = CentralManagerObserver()
		let central = CBCentralManager(delegate: centralDelegate,
		                                queue: queue,
		                                options: options)
		self.central = central

		self.state = Property<CBManagerState>(initial: CBManagerState.unknown,
		                                      then: centralDelegate
												.events
												.filter { $0.filter(central: central) }
												.filter { $0.isDidUpdateStateEvent() }
												.map { DidUpdateStateEvent(event: $0) }
												.skipNil()
												.map { $0.central.state })


	}

	/// Scans for peripherals with the specified services.
	/// Duplicates are ignored. Please make sure that the central is `poweredOn` before calling `scanForPeripherals`
	public func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?) -> SignalProducer<Peripheral, NoError> {

		let signal = centralDelegate
			.events
			.filter { $0.filter(central: self.central) }
			.filter { $0.isDidDiscoverEvent() }
			.map { DidDiscoverEvent(event: $0) }
			.skipNil()

		let resultProducer = SignalProducer(signal)
			.map { Peripheral(peripheral: $0.peripheral,
			                  central: self)
			}

		let producer = SignalProducer<Void, NoError> {
				self.central.scanForPeripherals(withServices: serviceUUIDs, options: [
					CBCentralManagerScanOptionAllowDuplicatesKey: false
					])
			}
			.then(resultProducer)
			.take(until: didStopScan)

		return producer
	}


	/// Stops scan.
	public func stopScan() -> SignalProducer<Void, NoError> {
		let producer = SignalProducer<Void, NoError> { observer, _ in
			self.central.stopScan()
			self.didStopScanObserver.send(value: ())

			observer.send(value: ())
			observer.sendCompleted()
		}

		return producer
	}

	internal func connect(to peripheral: Peripheral,
	                      options: [String: Any]? = nil) -> SignalProducer<Peripheral, NSError> {

		let signal = centralDelegate
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
				self.central.connect(peripheral.peripheral, options: options)
			}
			.then(resultProducer)

		return producer
	}

	internal func cancelPeripheralConnection(from peripheral: Peripheral) -> SignalProducer<Peripheral, NSError> {

		let signal = centralDelegate
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
