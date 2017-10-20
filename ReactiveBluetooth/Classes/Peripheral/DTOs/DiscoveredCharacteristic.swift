//
//  DiscoveredCharacteristic.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 19/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

public struct DiscoveredCharacteristic {
	public let peripheral: CBPeripheral
	public let service: CBService
	public let characteristic: CBCharacteristic
	public let delegate: PeripheralDelegate
}

extension DiscoveredCharacteristic: PeripheralProvider {}

extension DiscoveredCharacteristic: ServiceProvider {}

extension DiscoveredCharacteristic: CharacteristicProvider {}

extension DiscoveredCharacteristic: PeripheralDelegateProvider {}

extension DiscoveredCharacteristic {
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
