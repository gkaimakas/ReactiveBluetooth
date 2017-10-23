//
//  PeripheralConnection+Signal.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 23/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

public extension Signal where Value == Result<PeripheralConnection, PeripheralConnectionError>, Error == NoError {

	func filter(central: CBCentralManager) -> Signal<Value, Error> {
		return self.filter { $0.isIncluded(central: central) }
	}

	func filter(peripheral: CBPeripheral) -> Signal<Value, Error> {
		return self.filter { $0.isIncluded(peripheral: peripheral) }
	}

	func dematerializeValue() -> Signal<PeripheralConnection, PeripheralConnectionError> {
		return self.promoteError(PeripheralConnectionError.self)
			.flatMap(.latest) { (result:Result<PeripheralConnection, PeripheralConnectionError>) -> Signal<PeripheralConnection, PeripheralConnectionError> in
				switch result {
				case .success(let value):
					return Signal<PeripheralConnection, PeripheralConnectionError> { observer, _ in
						observer.send(value: value)
						observer.sendCompleted()
					}

				case .failure(let error):
					return Signal<PeripheralConnection, PeripheralConnectionError> { observer, _ in
						observer.send(error: error)
						observer.sendCompleted()
					}
				}
		}
	}
}
