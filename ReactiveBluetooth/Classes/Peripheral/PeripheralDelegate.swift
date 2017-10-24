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
	var events: Signal<PeripheralDelegateEvent, NoError> { get }
}

public extension PeripheralDelegate {
}

//public extension PeripheralDelegate {
//
//	func discoverCharacteristics(peripheral: CBPeripheral, service: CBService, uuids: [CBUUID]?) -> SignalProducer<DiscoveredCharacteristicsList, DiscoveredCharacteristicError> {
//
//		let signal = didDiscoverCharacteristics
//			.filter(peripheral: peripheral)
//			.filter(service: service.uuid)
//			.dematerializeValue()
//
//		let resultProducer = SignalProducer(signal)
//
//		return SignalProducer<Void, DiscoveredCharacteristicError> { peripheral.discoverCharacteristics(uuids, for: service) }
//			.then(resultProducer)
//			.take(first: 1)
//
//	}
//
//	/// Writes a value to the given `characteristic` of the peripheral and returns the result of the operation.
//	/// It is assumed that the CBCharacteristicWriteType is `.withResponse`
//	func writeValue(peripheral: CBPeripheral,
//	                characteristic: CBCharacteristic,
//	                value: Data) -> SignalProducer<WrittenValue, WrittenValueError> {
//
//		let signal = didWriteValue
//			.filter(peripheral: peripheral)
//			.filter(characteristic: characteristic.uuid)
//			.dematerializeValue()
//
//		let resultProducer = SignalProducer(signal)
//
//		return SignalProducer<Void, WrittenValueError> { peripheral.writeValue(value, for: characteristic, type: .withResponse) }
//			.then(resultProducer)
//			.take(first: 1)
//	}
//
//	/// Reads the value of the given `characteristic`
//	func readValue(peripheral: CBPeripheral, characteristic: CBCharacteristic) -> SignalProducer<UpdatedValue, UpdatedValueError> {
//		let signal = didUpdateValue
//			.filter(peripheral: peripheral)
//			.filter(characteristic: characteristic.uuid)
//			.dematerializeValue()
//
//		let resultProducer = SignalProducer(signal)
//
//		return SignalProducer<Void, UpdatedValueError> { peripheral.readValue(for: characteristic) }
//			.then(resultProducer)
//			.take(first: 1)
//	}
//
//	/// Enables/Disables notifications for the given peripheral
//	func setNotifyValue(peripheral: CBPeripheral, characteristic: CBCharacteristic, enabled: Bool = true) -> SignalProducer<UpdatedNotificationState, UpdatedNotificationStateError> {
//		let signal = didUpdateNotificationState
//			.filter(peripheral: peripheral)
//			.filter(characteristic: characteristic.uuid)
//			.dematerializeValue()
//
//		let resultProducer = SignalProducer(signal)
//
//		return SignalProducer<Void, UpdatedNotificationStateError> { peripheral.setNotifyValue(enabled, for: characteristic) }
//			.then(resultProducer)
//			.take(first: 1)
//	}
//}

