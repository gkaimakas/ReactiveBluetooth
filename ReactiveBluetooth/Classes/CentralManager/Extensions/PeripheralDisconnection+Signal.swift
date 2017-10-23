//
//  PeripheralDisconnection+Signal.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 23/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

public extension Signal where Value == Result<PeripheralDisconnection, PeripheralDisconnectionError>, Error == NoError {
	func filter(central: CBCentralManager) -> Signal<Value, Error> {
		return filter { $0.isIncluded(central: central) }
	}

	func filter(peripheral: CBPeripheral) -> Signal<Value, Error> {
		return filter { $0.isIncluded(peripheral: peripheral) }
	}

	func dematerializeValue() -> Signal<PeripheralDisconnection, PeripheralDisconnectionError> {
		return self.promoteError(PeripheralDisconnectionError.self)
			.flatMap(.latest) { (result:Result<PeripheralDisconnection, PeripheralDisconnectionError>) -> Signal<PeripheralDisconnection, PeripheralDisconnectionError> in
				switch result {
				case .success(let value):
					return Signal<PeripheralDisconnection, PeripheralDisconnectionError> { observer, _ in
						observer.send(value: value)
						observer.sendCompleted()
					}

				case .failure(let error):
					return Signal<PeripheralDisconnection, PeripheralDisconnectionError> { observer, _ in
						observer.send(error: error)
						observer.sendCompleted()
					}
				}
		}
	}
}
