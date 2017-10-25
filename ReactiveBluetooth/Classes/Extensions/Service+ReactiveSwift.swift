//
//  Service+ReactiveSwift.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 25/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

public extension Signal where Value: Service {
	func filter(service: Service) -> Signal<Value, Error> {
		return self.filter { $0.service == service.service }
	}

	func filter(service: CBUUID) -> Signal<Value, Error> {
		return self.filter { $0.uuid.value.isEqual(service) }
	}

	func filter(service: String) -> Signal<Value, Error> {
		return self.filter { $0.uuid.value.uuidString == service }
	}
}

public extension SignalProducer where Value: Service {
	func filter(service: Service) -> SignalProducer<Value, Error> {
		return self.lift { $0.filter(service: service) }
	}

	func filter(service: CBUUID) -> SignalProducer<Value, Error> {
		return self.lift { $0.filter(service: service) }
	}

	func filter(service: String) -> SignalProducer<Value, Error> {
		return self.lift { $0.filter(service: service) }
	}
}
