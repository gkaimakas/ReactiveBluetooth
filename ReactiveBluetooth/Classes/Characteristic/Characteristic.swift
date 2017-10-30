//
//  Characteristic.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 24/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveCocoa
import ReactiveSwift
import Result

public class Characteristic {
	let peripheral: Peripheral
	let characteristic: CBCharacteristic
	let delegate: PeripheralObserver

	/// The Bluetooth-specific UUID of the attribute.
	public let uuid: Property<CBUUID>

	/// The service that this characteristic belongs to.
	public let service: Service

	/// The value of the characteristic. It can be used to recieve notifications/updates
	public let value: Property<Data?>

	/// The properties of the characteristic.
	public let properties: Property<CBCharacteristicProperties>

	/// A list of the descriptors that have been discovered in this characteristic.
	public let descriptors: Property<Set<Descriptor>>

	/// A Boolean property indicating whether the characteristic is currently notifying a subscribed central of its value.
	public let isNotifying: Property<Bool>

	init(peripheral: Peripheral,
	     service: Service,
	     characteristic: CBCharacteristic,
	     delegate: PeripheralObserver) {

		weak var _self: Characteristic!

		self.peripheral = peripheral
		self.service = service
		self.characteristic = characteristic
		self.delegate = delegate

		self.value = Property<Data?>(initial: characteristic.value,
		                             then: delegate
										.events
										.filter { $0.isDidUpdateValueForCharacteristicEvent() }
										.filter { $0.filter(peripheral: peripheral.peripheral) }
										.filter { $0.filter(characteristic: characteristic.uuid) }
										.map { DidUpdateValueForCharacteristicEvent(event: $0) }
										.map { $0?.characteristic.value }
		)

		self.uuid = Property<CBUUID>(value: characteristic.uuid)
		self.properties = Property(value: characteristic.properties)
		
		self.descriptors = Property(initial: Set(),
		                            then: characteristic
										.reactive
										.producer(forKeyPath: #keyPath(CBCharacteristic.descriptors))
										.map { $0 as? [CBDescriptor] }
										.skipNil().map { $0.map { Descriptor(peripheral: peripheral,
										                                     characteristic: _self,
										                                     descriptor: $0,
										                                     delegate: delegate) }}
										.map { Set($0) }
		)

		self.isNotifying = Property<Bool>(initial: characteristic.isNotifying,
		                                  then: characteristic
											.reactive
											.signal(forKeyPath: #keyPath(CBCharacteristic.isNotifying))
											.map { $0 as? Bool }
											.skipNil()
		)

		_self = self
	}

	/// Discovers the descriptors of the characteristic.
	public func discoverDescriptors() -> SignalProducer<Descriptor, NSError> {
		let signal = delegate
			.events
			.filter { $0.filter(peripheral: self.peripheral.peripheral) }
			.filter { $0.filter(characteristic: self.characteristic) }
			.filter { $0.isDidDiscoverDescriptorsEvent() }
			.map { DidDiscoverDescriptorsEvent(event: $0) }
			.skipNil()

		let resultProducer = SignalProducer(signal)
			.take(first: 1)
			.flatMap(.latest) { event -> SignalProducer<Descriptor, NSError> in
				if let error = event.error as NSError? {
					return SignalProducer(error: error)
				}

				if let descriptors = event.characteristic.descriptors {
					let result = descriptors.map { Descriptor(peripheral: self.peripheral,
					                                          characteristic: self,
					                                          descriptor: $0,
					                                          delegate: self.delegate)}
					return SignalProducer(result)
				}

				return SignalProducer.empty
			}

		let producer = SignalProducer<Void, NSError> {
				self.peripheral
					.peripheral
					.discoverDescriptors(for: self.characteristic)
			}
			.then(resultProducer)

		return producer
	}

	/// Retrieves the value of the characteristic.
	public func readValue() -> SignalProducer<Data?, NSError> {
		let signal = delegate
			.events
			.filter { $0.filter(peripheral: self.peripheral.peripheral) }
			.filter { $0.filter(characteristic: self.characteristic) }
			.filter { $0.isDidUpdateValueForCharacteristicEvent() }
			.map { DidUpdateValueForCharacteristicEvent(event: $0) }
			.skipNil()

		let resultProducer = SignalProducer(signal)
			.take(first: 1)
			.flatMap(.latest) { event -> SignalProducer<Data?, NSError> in
				if let error = event.error as NSError? {
					return SignalProducer(error: error)
				}

				return SignalProducer(value: event.characteristic.value)
			}

		let producer = SignalProducer<Void, NSError> {
				self.peripheral
					.peripheral
					.readValue(for: self.characteristic)
			}
			.then(resultProducer)

		return producer
	}

	/// Writes data to the peripheral and awaits a response
	public func write(value data: Data) -> SignalProducer<Data, NSError> {
		let signal = delegate
			.events
			.filter { $0.filter(peripheral: self.peripheral.peripheral) }
			.filter { $0.filter(characteristic: self.characteristic.uuid) }
			.filter { $0.isDidWriteValueForCharacteristicEvent() }
			.map { DidWriteValueForCharacteristicEvent(event: $0) }
			.skipNil()

		let resultProducer = SignalProducer(signal)
			.take(first: 1)
			.flatMap(.latest) { event -> SignalProducer<Data, NSError> in
				if let error = event.error as NSError? {
					return SignalProducer(error: error)
				}

				return SignalProducer(value: data)
			}

		let producer = SignalProducer<Void, NSError> {
				self.peripheral
					.peripheral
					.writeValue(data, for: self.characteristic, type: .withResponse)
			}
			.then(resultProducer)

		return producer
	}

	/// Writes data to the peripheral without awaiting a response
	public func send(data: Data) -> SignalProducer<Data, NoError> {
		return SignalProducer<Void, NoError> {
			self.peripheral
				.peripheral
				.writeValue(data, for: self.characteristic, type: .withoutResponse)
			}
			.map { _ in data }
	}

	/// Sets notifications or indications for the value of the characteristic.
	public func setNotify(enabled: Bool) -> SignalProducer<Bool, NSError> {
		let signal = delegate
			.events
			.filter { $0.isDidUpdateNotificationStateEvent() }
			.filter { $0.filter(peripheral: self.peripheral.peripheral) }
			.filter { $0.filter(characteristic: self.characteristic) }
			.map { DidUpdateNotificationStateEvent(event: $0) }
			.skipNil()

		let resultProducer = SignalProducer(signal)
			.take(first: 1)
			.flatMap(.latest) { event -> SignalProducer<Bool, NSError> in
				if let error = event.error as NSError? {
					return SignalProducer(error: error)
				}

				return SignalProducer(value: event.characteristic.isNotifying)
			}

		let producer = SignalProducer<Void, NSError> {
				self.peripheral
					.peripheral
					.setNotifyValue(enabled, for: self.characteristic)
			}
			.then(resultProducer)

		return producer
	}
}

// MARK: - Hashable

extension Characteristic: Hashable {
	public var hashValue: Int {
		return characteristic.hashValue
	}

	public static func ==(lhs: Characteristic, rhs: Characteristic) -> Bool {
		return lhs.uuid.value == rhs.uuid.value
	}
}
