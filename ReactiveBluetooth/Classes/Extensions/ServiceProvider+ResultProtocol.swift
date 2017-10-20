//
//  ServiceProvider+Result.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation
import Result

public extension ResultProtocol where Value: ServiceProvider, Error: ServiceProviderError {
	func isIncluded(service: CBService) -> Bool {

		if let value = self.value {
			return value.service == service
		}

		if let error = self.error {
			return error.service == service
		}

		return false
	}

	func isIncluded(service: CBUUID) -> Bool {

		if let value = self.value {
			return value.service.uuid.isEqual(service)
		}

		if let error = self.error {
			return error.service.uuid.isEqual(service)
		}

		return false
	}

	func isIncluded(service: String) -> Bool {

		if let value = self.value {
			return value.service.uuid.uuidString == service
		}

		if let error = self.error {
			return error.service.uuid.uuidString == service
		}

		return false
	}
}
