//
//  ServiceProvider+Signal.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

public extension Signal where Value: ResultProtocol, Value.Value: ServiceProvider, Value.Error: ServiceProviderError, Error == NoError {

	func filter(service: CBService) -> Signal<Value, Error> {
		return filter { $0.isIncluded(service: service) }
	}

	func filter(service: CBUUID) -> Signal<Value, Error> {
		return filter { $0.isIncluded(service: service) }
	}

	func filter(service: String) -> Signal<Value, Error> {
		return filter { $0.isIncluded(service: service) }
	}
}

public extension Signal where Value: ServiceProvider {
	func filter(service: CBService) -> Signal<Value, Error> {
		return filter { $0.service == service }
	}

	func filter(service: CBUUID) -> Signal<Value, Error> {
		return filter { $0.service.uuid.isEqual(service) }
	}

	func filter(service: String) -> Signal<Value, Error> {
		return filter { $0.service.uuid.uuidString == service }
	}
}
