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
	internal let delegate: PeripheralObserver
	internal let service: CBService

	public let peripheral: Peripheral
	public let isPrimary: Property<Bool>

	public private(set) var includedServices: Set<Service>

	public var uuid: CBUUID {
		return service.uuid
	}

	internal init(peripheral: Peripheral,
	              service: CBService,
	              delegate: PeripheralObserver) {

		self.peripheral = peripheral
		self.service = service
		self.delegate = delegate

		self.isPrimary = Property<Bool>(value: service.isPrimary)

		self.includedServices = Set<Service>()
	}

	/// Discovers the specified included services of a service.
	public func discoverIncludedServices( _ includedServiceUUID: [CBUUID]? = nil) -> SignalProducer<IncludedService, NSError> {
		let signal = delegate
			.events
			.filter { $0.isDidDiscoverIncludedServicesEvent() }
			.filter { $0.filter(peripheral: self.peripheral.peripheral) }
			.filter { $0.filter(service: self.service.uuid) }
			.map { DidDiscoverIncludedServicesEvent(event: $0) }
			.skipNil()

		let resultProducer = SignalProducer(signal)
			.take(first: 1)
			.flatMap(.latest) { event -> SignalProducer<IncludedService, NSError> in
				if let error = event.error as NSError? {
					return SignalProducer(error: error)
				}

				if let includedServices = event.service.includedServices {
					let result = includedServices
						.map { IncludedService(peripheral: self.peripheral,
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

	/// Discovers the specified characteristics of a service.
	public func discoverCharacteristics(_ characteristicsUUIDs: [CBUUID]? = nil) -> SignalProducer<Characteristic, NSError> {
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

extension Service: Hashable {
	public var hashValue: Int {
		return service.hashValue
	}

	public static func ==(lhs: Service, rhs: Service) -> Bool {
		return lhs.uuid.uuidString == rhs.uuid.uuidString
			&& lhs.service == rhs.service
	}

}
