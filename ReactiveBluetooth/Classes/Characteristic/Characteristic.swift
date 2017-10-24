//
//  Characteristic.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 24/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

public class Characteristic {
	let peripheral: CBPeripheral
	let service: CBService
	let characteristic: CBCharacteristic
	let delegate: PeripheralObserver

	public var uuid: CBUUID {
		return characteristic.uuid
	}

	public let value: Property<Data?>

	init(peripheral: CBPeripheral,
	     service: CBService,
	     characteristic: CBCharacteristic,
	     delegate: PeripheralObserver) {

		self.peripheral = peripheral
		self.service = service
		self.characteristic = characteristic
		self.delegate = delegate

		self.value = Property<Data?>(initial: nil, then: delegate
			.events
			.filter { $0.isDidUpdateValueEvent() }
			.filter { $0.filter(peripheral: peripheral) }
			.filter { $0.filter(characteristic: characteristic.uuid) }
			.map { DidUpdateValueEvent(event: $0) }
			.map { $0?.characteristic.value }
		)
	}

	public func readValue() -> SignalProducer<Data?, NSError> {
		let signal = delegate
			.events
			.filter { $0.filter(peripheral: self.peripheral) }
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
				self.peripheral.readValue(for: self.characteristic)
			}
			.then(resultProducer)

		return producer
	}

	/// Writes data to the peripheral and awaits a response
	public func write(data: Data) -> SignalProducer<Data, NSError> {
		let signal = delegate
			.events
			.filter { $0.filter(peripheral: self.peripheral) }
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
				self.peripheral.writeValue(data, for: self.characteristic, type: .withResponse)
			}
			.then(resultProducer)

		return producer
	}

	/// Writes data to the peripheral without awaiting a response
	public func send(data: Data) -> SignalProducer<Data, NSError> {
		return SignalProducer<Data, NSError> { observer, _ in
			self.peripheral.writeValue(data, for: self.characteristic, type: .withoutResponse)
			observer.send(value: data)
			observer.sendCompleted()
		}
	}

	public func setNotify(enabled: Bool) -> SignalProducer<Bool, NSError> {
		let signal = delegate
			.events
			.filter { $0.isDidUpdateNotificationStateEvent() }
			.filter { $0.filter(peripheral: self.peripheral) }
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
				self.peripheral.setNotifyValue(enabled, for: self.characteristic)
			}
			.then(resultProducer)

		return producer
	}
}
