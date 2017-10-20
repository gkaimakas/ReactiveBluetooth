//
//  WrittenValue.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 19/10/2017.
//

import CoreBluetooth
import Foundation

public struct WrittenValue {
	public let peripheral: CBPeripheral
	public let characteristic: CBCharacteristic
	public let value: Data?

	public init(peripheral: CBPeripheral,
	            characteristic: CBCharacteristic) {

		self.peripheral = peripheral
		self.characteristic = characteristic
		self.value = characteristic.value
	}
}
