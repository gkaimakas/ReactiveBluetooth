//
//  PeripheralProvider+Result.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation
import Result

public extension ResultProtocol where Value: PeripheralProvider, Error: PeripheralProviderError {
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
