//
//  UpdatedNotificationState.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 19/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

public struct UpdatedNotificationState {
	public let peripheral: CBPeripheral
	public let characteristic: CBCharacteristic
	public let isNotifying: Bool
	public let delegate: PeripheralDelegate

	public init(peripheral: CBPeripheral,
	            characteristic: CBCharacteristic,
	            delegate: PeripheralDelegate) {
		self.peripheral = peripheral
		self.characteristic = characteristic
		self.isNotifying = characteristic.isNotifying
		self.delegate = delegate
	}
}

extension UpdatedNotificationState: PeripheralProvider {}

extension UpdatedNotificationState: CharacteristicProvider {}

extension UpdatedNotificationState: PeripheralDelegateProvider {}

extension UpdatedNotificationState {
	func readValue() -> SignalProducer<UpdatedValue, UpdatedValueError> {
		return delegate.readValue(peripheral: peripheral, characteristic: characteristic)
	}

	func writeValue(_ data: Data) -> SignalProducer<WrittenValue, WrittenValueError> {
		return delegate.writeValue(peripheral: peripheral, characteristic: characteristic, value: data)
	}

	func setNotifyValue(_ enabled: Bool) -> SignalProducer<UpdatedNotificationState, UpdatedNotificationStateError> {
		return delegate.setNotifyValue(peripheral: peripheral, characteristic: characteristic, enabled: enabled)
	}
}

