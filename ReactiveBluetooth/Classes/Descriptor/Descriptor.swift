//
//  Descriptor.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 26/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveCocoa
import ReactiveSwift
import Result

public class Descriptor {
	let peripheral: Peripheral
	let delegate: PeripheralObserver
	let descriptor: CBDescriptor

	/// Retrieves the value of the descriptor.
	fileprivate let _readValue: Action<Void, Any?, NSError>

	/// Writes the value of the descriptor.
	fileprivate let _writeValue: Action<Data, Any?, NSError>

	public let characteristic: Characteristic

	/// The Bluetooth-specific UUID of the attribute.
	public let uuid: Property<CBUUID>

	/// The value of the descriptor.
	public let value: Property<Any?>

	internal init(peripheral: Peripheral,
	              characteristic: Characteristic,
	              descriptor: CBDescriptor,
	              delegate: PeripheralObserver) {

		weak var _self: Descriptor!

		self.peripheral = peripheral
		self.characteristic = characteristic
		self.descriptor = descriptor
		self.delegate = delegate

		self.uuid = Property(value: descriptor.uuid)

		self.value = Property(initial: descriptor.value,
		                      then: descriptor
								.reactive
								.producer(forKeyPath: #keyPath(CBDescriptor.value))
		)

		self._readValue = Action(enabledIf: peripheral.state.isConnected,
		                        execute: { _ in _self.readValue() })

		self._writeValue = Action(enabledIf: peripheral.state.isConnected,
		                        execute: { data in _self.write(value: data) })

		_self = self
	}

	/// Retrieves the value of the characteristic descriptor.
	public func readValue() -> SignalProducer<Any?, NSError> {
		let signal = delegate
			.events
			.filter { $0.filter(peripheral: self.peripheral.peripheral) }
			.filter { $0.filter(descriptor: self.descriptor) }
			.filter { $0.isDidUpdateValueForDescriptorEvent() }
			.map { DidUpdateValueForDescriptorEvent(event: $0) }
			.skipNil()

		let resultProducer = SignalProducer(signal)
			.take(first: 1)
			.flatMap(.latest) { event -> SignalProducer<Any?, NSError> in
				if let error = event.error as NSError? {
					return SignalProducer(error: error)
				}
				return SignalProducer(value: event.descriptor.value)
		}

		let producer = SignalProducer<Void, NSError> {
				self.peripheral
					.peripheral
					.readValue(for: self.descriptor)
			}
			.then(resultProducer)

		return producer
	}

	/// Writes the value of a characteristic descriptor.
	public func write(value data: Data) -> SignalProducer<Any?, NSError> {
		let signal = delegate
			.events
			.filter { $0.filter(peripheral: self.peripheral.peripheral) }
			.filter { $0.filter(descriptor: self.descriptor) }
			.filter { $0.isDidWriteValueForDescriptorEvent() }
			.map { DidWriteValueForDescriptorEvent(event: $0) }
			.skipNil()

		let resultProducer = SignalProducer(signal)
			.take(first: 1)
			.flatMap(.latest) { event -> SignalProducer<Any?, NSError> in
				if let error = event.error as NSError? {
					return SignalProducer(error: error)
				}
				return SignalProducer(value: event.descriptor.value)
		}

		let producer = SignalProducer<Void, NSError> {
			self.peripheral
				.peripheral
				.writeValue(data, for: self.descriptor)
			}
			.then(resultProducer)

		return producer

	}
}

// MARK: - Hashable

extension Descriptor: Hashable {
	public var hashValue: Int {
		return descriptor.hashValue
	}

	public static func ==(lhs: Descriptor, rhs: Descriptor) -> Bool {
		return lhs.uuid.value == rhs.uuid.value
	}
}

// MARK: - NonBlocking

extension Descriptor: ActionableProvider {}

public extension Actionable where Base: Descriptor {
	/// Retrieves the value of the characteristic descriptor.
	public var readValue: Action<Void, Any?, NSError> {
		return base._readValue
	}

	/// Writes the value of a characteristic descriptor.
	public var writeValue: Action<Data, Any?, NSError> {
		return base._writeValue
	}
}

