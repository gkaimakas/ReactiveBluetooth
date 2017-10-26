//
//  Service.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 24/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

public class Service {
	let delegate: PeripheralObserver
	let service: CBService

	/// The Bluetooth-specific UUID of the attribute.
	public let uuid: Property<CBUUID>

	/// The peripheral to which this service belongs.
	public let peripheral: Peripheral

	/// A Boolean property indicating whether the type of service is primary or secondary.
	public let isPrimary: Property<Bool>

	/// A list of characteristics that have been discovered in this service.
	public let characteristics: Property<Set<Characteristic>>

	/// A list of included services that have been discovered in this service.
	public let includedServices: Property<Set<Service>>

	/// Discovers the specified included services of this service.
	public let discoverIncludedServices: Action<[CBUUID]?, Service, NSError>

	/// Discovers the specified characteristics of the service.
	public let discoverCharacteristics: Action<[CBUUID]?, Characteristic, NSError>

	internal init(peripheral: Peripheral,
	              service: CBService,
	              delegate: PeripheralObserver) {

		weak var _self: Service!

		self.peripheral = peripheral
		self.service = service
		self.delegate = delegate

		self.uuid = Property<CBUUID>(value: service.uuid)
		self.isPrimary = Property<Bool>(value: service.isPrimary)

		self.characteristics = Property(initial: Set(),
		                                 then: service
											.reactive
											.producer(forKeyPath: #keyPath(CBService.characteristics))
											.map { $0 as? [CBCharacteristic] }
											.skipNil()
											.map { $0.map { Characteristic(peripheral: peripheral,
											                               service: _self,
											                               characteristic: $0,
											                               delegate: delegate)}}
											.map { Set($0) }
		)

		self.includedServices = Property(initial: Set(),
		                                 then: service
											.reactive
											.producer(forKeyPath: #keyPath(CBService.includedServices))
											.map { $0 as? [CBService] }
											.skipNil()
											.map { $0.map { Service(peripheral: peripheral,
											                                service: $0,
											                                delegate: delegate)}}
											.map { Set($0) }
		)

		self.discoverIncludedServices = Action(enabledIf: peripheral.state.isConnected,
		                                       execute: { uuids in return _self._discoverIncludedServices(uuids) })


		self.discoverCharacteristics = Action(enabledIf: peripheral.state.isConnected,
		                                       execute: { uuids in return _self._discoverCharacteristics(uuids) })

		_self = self

	}

	/// Discovers the specified included services of this service.
	fileprivate func _discoverIncludedServices(_ includedServiceUUID: [CBUUID]? = nil) -> SignalProducer<Service, NSError> {
		let signal = delegate
			.events
			.filter { $0.isDidDiscoverIncludedServicesEvent() }
			.filter { $0.filter(peripheral: self.peripheral.peripheral) }
			.filter { $0.filter(service: self.service.uuid) }
			.map { DidDiscoverIncludedServicesEvent(event: $0) }
			.skipNil()

		let resultProducer = SignalProducer(signal)
			.take(first: 1)
			.flatMap(.latest) { event -> SignalProducer<Service, NSError> in
				if let error = event.error as NSError? {
					return SignalProducer(error: error)
				}

				if let includedServices = event.service.includedServices {
					let result = includedServices
						.map { Service(peripheral: self.peripheral,
						                       service: $0,
						                       delegate: self.delegate)

						}

					return SignalProducer(result)
				}

				return SignalProducer.empty
			}

		let producer = SignalProducer<Void, NSError> {
				self.peripheral
					.peripheral
					.discoverIncludedServices(includedServiceUUID, for: self.service)
			}
			.then(resultProducer)

		return producer
	}

	/// Discovers the specified characteristics of the service.
	fileprivate func _discoverCharacteristics(_ characteristicsUUIDs: [CBUUID]? = nil) -> SignalProducer<Characteristic, NSError> {
		let signal = delegate
			.events
			.filter { $0.isDidDiscoverCharacteristicsEvent() }
			.filter { $0.filter(peripheral: self.peripheral.peripheral) }
			.filter { $0.filter(service: self.service.uuid) }
			.map { DidDiscoverCharacteristicsEvent(event: $0) }
			.skipNil()

		let resultProducer = SignalProducer(signal)
			.take(first: 1)
			.flatMap(.latest) { event -> SignalProducer<Characteristic, NSError> in
				if let error = event.error as NSError? {
					return SignalProducer(error: error)
				}

				if let characteristics = event.service.characteristics {
					let result = characteristics
						.map { Characteristic(peripheral: self.peripheral,
						                      service: self,
						                      characteristic: $0,
						                      delegate: self.delegate) }
					return SignalProducer(result)
				}

				return SignalProducer.empty
		}

		let producer = SignalProducer<Void, NSError> {
				self.peripheral
					.peripheral
					.discoverCharacteristics(characteristicsUUIDs, for: self.service)
			}
			.then(resultProducer)

		return producer
	}
}

// MARK: - Hashable

extension Service: Hashable {
	public var hashValue: Int {
		return service.hashValue
	}

	public static func ==(lhs: Service, rhs: Service) -> Bool {
		return lhs.uuid.value == rhs.uuid.value
	}
}

// MARK: - NonBlocking

extension Service: NonBlockingProvider {}

extension NonBlocking where Base: Service {
	
	/// Discovers the specified included services of this service.
	public func discoverIncludedServices(_ includedServiceUUID: [CBUUID]? = nil) -> SignalProducer<Service, NSError> {
		return base._discoverIncludedServices(includedServiceUUID)
	}

	/// Discovers the specified characteristics of the service.
	public func discoverCharacteristics(_ characteristicsUUIDs: [CBUUID]? = nil) -> SignalProducer<Characteristic, NSError> {
		return base._discoverCharacteristics(characteristicsUUIDs)
	}
}
