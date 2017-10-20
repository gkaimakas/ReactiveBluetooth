//
//  CharacteristicProvider+Result.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation
import Result

public extension ResultProtocol where Value: CharacteristicProvider, Error: CharacteristicProviderError {
	func isIncluded(characteristic: CBCharacteristic) -> Bool {
		if let value = self.value {
			return value.characteristic == characteristic
		}

		if let error = self.error {
			return error.characteristic == characteristic
		}

		return false
	}

	func isIncluded(characteristic: CBUUID) -> Bool {
		if let value = self.value {
			return value.characteristic.uuid.isEqual(characteristic)
		}

		if let error = self.error {
			return error.characteristic.uuid.isEqual(characteristic)
		}

		return false
	}

	func isIncluded(characteristic: String) -> Bool {
		if let value = self.value {
			return value.characteristic.uuid.uuidString == characteristic
		}

		if let error = self.error {
			return error.characteristic.uuid.uuidString == characteristic
		}

		return false
	}
}
