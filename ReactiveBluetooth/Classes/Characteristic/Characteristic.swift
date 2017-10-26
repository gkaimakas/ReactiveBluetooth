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

	/// Discovers the descriptors of the characteristic.
	fileprivate let _discoverDescriptors: Action<Void, Descriptor, NSError>

	/// Retrieves the value of the characteristic.
	fileprivate let _readValue: Action<Void, Data?, NSError>

	/// Writes data to the peripheral and awaits a response
	fileprivate let _writeValue: Action<Data, Data, NSError>

	/// Writes data to the peripheral without awaiting a response
	fileprivate let _sendData: Action<Data, Data, NoError>

	/// Sets notifications or indications for the value of the characteristic.
	fileprivate let _setNotify: Action<Bool, Bool, NSError>

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

		self._discoverDescriptors = Action(enabledIf: peripheral.state.isConnected,
		                                  execute: { _  in _self.discoverDescriptors() })

		self._readValue = Action(enabledIf: peripheral.state.isConnected,
		                        execute: { _ in _self.readValue() })

		self._writeValue = Action(enabledIf: peripheral.state.isConnected,
		                         execute: { value in _self.write(value: value) })

		self._sendData = Action(enabledIf: peripheral.state.isConnected,
		                         execute: { value in _self.send(data: value) })

		self._setNotify = Action(enabledIf: peripheral.state.isConnected,
		                        execute: { value in _self.setNotify(enabled: value) })

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

// MARK: - NonBlocking

extension Characteristic: ActionableProvider {}

public extension Actionable where Base: Characteristic {

	/// Discovers the descriptors of the characteristic.
	public var discoverDescriptors: Action<Void, Descriptor, NSError> {
		return base._discoverDescriptors
	}

	/// Retrieves the value of the characteristic.
	public var readValue: Action<Void, Data?, NSError> {
		return base._readValue
	}

	/// Writes data to the peripheral and awaits a response
	public var write: Action<Data, Data, NSError> {
		return base._writeValue
	}

	/// Writes data to the peripheral without awaiting a response
	public var send: Action<Data, Data, NoError> {
		return base._sendData
	}

	/// Sets notifications or indications for the value of the characteristic.
	public var setNotify: Action<Bool, Bool, NSError> {
		return base._setNotify
	}
}
