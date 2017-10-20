//
//  PeripheralDelegate.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

public protocol PeripheralDelegate: CBPeripheralDelegate {
	var didUpdateName: Signal<UpdatedName, NoError> { get }
	var didReadRSSI: Signal<Result<ReadRSSI, ReadRSSIError>, NoError> { get }
	var didDiscoverService: Signal<Result<DiscoveredService, DiscoveredServiceError>, NoError> { get }
	var didDiscoverCharacteristic: Signal<Result<DiscoveredCharacteristic, DiscoveredCharacteristicError>, NoError> { get }
	var didUpdateNotificationState: Signal<Result<UpdatedNotificationState, UpdatedNotificationStateError>, NoError> { get }
	var didWriteValue: Signal<Result<WrittenValue, WrittenValueError>, NoError> { get }
	var didUpdateValue: Signal<Result<UpdatedValue, UpdatedValueError>, NoError> { get }

	func writeValue(peripheral: CBPeripheral,
	                characteristic: CBCharacteristic,
	                value: Data) -> SignalProducer<WrittenValue, WrittenValueError>

	func readValue(peripheral: CBPeripheral, characteristic: CBCharacteristic) -> SignalProducer<UpdatedValue, UpdatedValueError>
	func setNotifyValue(peripheral: CBPeripheral, characteristic: CBCharacteristic, enabled: Bool) -> SignalProducer<UpdatedNotificationState, UpdatedNotificationStateError>
}

public extension PeripheralDelegate {

	/// Writes a value to the given `characteristic` of the peripheral and returns the result of the operation.
	/// It is assumed that the CBCharacteristicWriteType is `.withResponse`
	func writeValue(peripheral: CBPeripheral,
	                characteristic: CBCharacteristic,
	                value: Data) -> SignalProducer<WrittenValue, WrittenValueError> {

		let signal = didWriteValue
			.filter(peripheral: peripheral)
			.filter(characteristic: characteristic.uuid)
			.dematerializeValue()

		let resultProducer = SignalProducer(signal)

		return SignalProducer<Void, WrittenValueError> { peripheral.writeValue(value, for: characteristic, type: .withResponse) }
			.then(resultProducer)
			.take(first: 1)
	}

	/// Reads the value of the given `characteristic`
	func readValue(peripheral: CBPeripheral, characteristic: CBCharacteristic) -> SignalProducer<UpdatedValue, UpdatedValueError> {
		let signal = didUpdateValue
			.filter(peripheral: peripheral)
			.filter(characteristic: characteristic.uuid)
			.dematerializeValue()

		let resultProducer = SignalProducer(signal)

		return SignalProducer<Void, UpdatedValueError> { peripheral.readValue(for: characteristic) }
			.then(resultProducer)
			.take(first: 1)
	}

	/// Enables/Disables notifications for the given peripheral
	func setNotifyValue(peripheral: CBPeripheral, characteristic: CBCharacteristic, enabled: Bool = true) -> SignalProducer<UpdatedNotificationState, UpdatedNotificationStateError> {
		let signal = didUpdateNotificationState
			.filter(peripheral: peripheral)
			.filter(characteristic: characteristic.uuid)
			.dematerializeValue()

		let resultProducer = SignalProducer(signal)

		return SignalProducer<Void, UpdatedNotificationStateError> { peripheral.setNotifyValue(enabled, for: characteristic) }
			.then(resultProducer)
			.take(first: 1)
	}
}
