//
//  Peripheral.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 24/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveCocoa
import ReactiveSwift
import Result

public class Peripheral {
	let peripheral: CBPeripheral
	private let central: CentralManager
	let delegate: PeripheralObserver

	/// The name of the peripheral.
	public let name: Property<String?>

	/// The UUID associated with the peer.
	public let identifier: Property<UUID>

	/// The current connection state of the peripheral.
	public let state: Property<CBPeripheralState>

	/// A list of services on the peripheral that have been discovered.
	public let services: Property<Set<Service>>

	public let canSendWriteWithoutResponse: Property<Bool>

	internal init(peripheral: CBPeripheral,
	              central: CentralManager)
	{

		weak var _self: Peripheral!
		self.peripheral = peripheral
		self.delegate = PeripheralObserver()
		self.central = central
		self.peripheral.delegate = self.delegate

		self.name = Property(initial: peripheral.name,
		                              then: delegate
										.events
										.filter { $0.filter(peripheral: peripheral) }
										.filter { $0.isDidUpdateNameEvent() }
										.map { DidUpdateNameEvent(event: $0) }
										.map { $0?.peripheral.name }
		)

		self.identifier = Property(value: peripheral.identifier)

		self.state = Property(initial: CBPeripheralState.disconnected,
		                                         then: peripheral
													.reactive
													.producer(forKeyPath: #keyPath(CBPeripheral.state))
													.map { $0 as? Int }
													.skipNil()
													.map { CBPeripheralState.init(rawValue: $0) }
													.skipNil()
			)
			.skipRepeats()

		self.services = Property(initial: Set(),
		                         then: peripheral
									.reactive
									.producer(forKeyPath: #keyPath(CBPeripheral.services))
									.map { $0 as? [CBService] }
									.skipNil()
									.map { $0.map { Service(peripheral: _self,
									                        service: $0,
									                        delegate: _self.delegate)
										}
									}
									.map { Set($0) }
		)

		self.canSendWriteWithoutResponse = Property<Bool>(value: peripheral.canSendWriteWithoutResponse)
		
		_self = self
	}

	/// Establishes a local connection to this peripheral
	public func connect(options: [String: Any]? = nil) -> SignalProducer<Peripheral, NSError> {
		return central.connect(to: self, options: options)
	}

	/// Cancels an active or pending local connection to this peripheral.
	public func disconnect() -> SignalProducer<Peripheral, NSError> {
		return central.cancelPeripheralConnection(from: self)
	}

	/// Discovers the specified services of the peripheral.
	public func discoverServices(_ servicesUUIDs: [CBUUID]? = nil) -> SignalProducer<Service, NSError> {

		let signal = delegate
			.events
			.filter { $0.filter(peripheral: self.peripheral) }
			.filter { $0.isDidDiscoverServicesEvent() }
			.map { DidDiscoverServicesEvent(event: $0) }
			.skipNil()

		let resultProducer = SignalProducer(signal)
			.take(first: 1)
			.flatMap(.latest) { event -> SignalProducer<Service, NSError> in
				if let error = event.error as NSError? {
					return SignalProducer.init(error: error)
				}

				if let services = event.peripheral.services {
					let result = services
						.map { Service(peripheral: self,
						               service: $0,
						               delegate: self.delegate)
							
					}

					return SignalProducer.init(result)
				}

				return SignalProducer.empty
			}

		let producer = SignalProducer<Void, NSError>.init {
				self.peripheral.discoverServices(servicesUUIDs)
			}
			.then(resultProducer)

		return producer
	}

	/// Retrieves the current RSSI value for the peripheral while it is connected to the central manager.
	public func readRSSI() -> SignalProducer<NSNumber, NSError> {

		let signal = delegate
			.events
			.filter { $0.filter(peripheral: self.peripheral) }
			.filter { $0.isDidReadRSSIEvent() }
			.map { DidReadRSSIEvent(event: $0) }
			.skipNil()

		let resultProducer = SignalProducer(signal)
			.take(first: 1)
			.flatMap(.latest) { event -> SignalProducer<NSNumber, NSError> in
				if let error = event.error as NSError? {
					return SignalProducer.init(error: error)
				}

				return SignalProducer.init(value: event.RSSI)
			}

		let producer = SignalProducer<Void, NSError>.init {
				self.peripheral.readRSSI()
			}
			.then(resultProducer)

		return producer
	}
}

// MARK: - Hashable

extension Peripheral: Hashable {
	public var hashValue: Int {
		return peripheral.hashValue
	}

	public static func ==(lhs: Peripheral, rhs: Peripheral) -> Bool {
		return lhs.peripheral == rhs.peripheral
	}
}
