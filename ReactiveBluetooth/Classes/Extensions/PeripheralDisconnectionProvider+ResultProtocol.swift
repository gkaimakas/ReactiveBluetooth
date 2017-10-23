//
//  PeripheralDisconnectionProvider+ResultProtocol.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 23/10/2017.
//

import CoreBluetooth
import Foundation
import Result

public extension ResultProtocol where Value: PeripheralDisconnectionProvider, Error: PeripheralDisconnectionErrorProvider {
	func isIncluded(central: CBCentralManager) -> Bool {

		if let value = self.value {
			return value.central == central
		}

		if let error = self.error {
			return error.central == central
		}

		return false
	}

	func isIncluded(peripheral: CBPeripheral) -> Bool {

		if let value = self.value {
			return value.peripheral == peripheral
		}

		if let error = self.error {
			return error.peripheral == peripheral
		}

		return false
	}
}
