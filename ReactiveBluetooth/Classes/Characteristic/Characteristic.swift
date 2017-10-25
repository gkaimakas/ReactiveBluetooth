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

	/// A Boolean property indicating whether the characteristic is currently notifying a subscribed central of its value.
	public let isNotifying: Property<Bool>

	init(peripheral: Peripheral,
	     service: Service,
	     characteristic: CBCharacteristic,
	     delegate: PeripheralObserver) {

		self.peripheral = peripheral
		self.service = service
		self.characteristic = characteristic
		self.delegate = delegate

		self.value = Property<Data?>(initial: characteristic.value,
		                             then: delegate
										.events
										.filter { $0.isDidUpdateValueEvent() }
										.filter { $0.filter(peripheral: peripheral.peripheral) }
										.filter { $0.filter(characteristic: characteristic.uuid) }
										.map { DidUpdateValueEvent(event: $0) }
										.map { $0?.characteristic.value }
		)

		self.uuid = Property<CBUUID>(value: characteristic.uuid)
		self.properties = Property(value: characteristic.properties)
		self.isNotifying = Property<Bool>(initial: characteristic.isNotifying,
		                                  then: characteristic
											.reactive
											.signal(forKeyPath: #keyPath(CBCharacteristic.isNotifying))
											.map { $0 as? Bool }
											.skipNil()
		)
	}

	/// Retrieves the value of the characteristic.
	public func readValue() -> SignalProducer<Data?, NSError> {
		let signal = delegate
			.events
			.filter { $0.filter(peripheral: self.peripheral.peripheral) }
			.filter { $0.filter(characteristic: self.characteristic.uuid) }
			.filter { $0.isDidUpdateValueEvent() }
			.map { DidUpdateValueEvent(event: $0) }
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
			.filter { $0.isDidWriteValueEvent() }
			.map { DidWriteValueEvent(event: $0) }
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
	public func send(data: Data) -> SignalProducer<Data, NSError> {
		return SignalProducer<Void, NSError> {
			self.peripheral
				.peripheral
				.writeValue(data, for: self.characteristic, type: .withoutResponse)
			}
			.map { _ in data }
	}

	/// Sets notifications or indications for the value of a specified characteristic.
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
