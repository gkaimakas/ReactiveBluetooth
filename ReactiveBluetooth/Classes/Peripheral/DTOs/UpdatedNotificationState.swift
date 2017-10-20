//
//  UpdatedNotificationState.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 19/10/2017.
//

import CoreBluetooth
import Foundation

public struct UpdatedNotificationState {
	public let peripheral: CBPeripheral
	public let characteristic: CBCharacteristic
	public let isNotifying: Bool

	public init(peripheral: CBPeripheral,
	            characteristic: CBCharacteristic) {
		self.peripheral = peripheral
		self.characteristic = characteristic
		self.isNotifying = characteristic.isNotifying
	}
}
