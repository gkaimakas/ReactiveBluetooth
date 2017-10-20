//
//  UpdatedValue+Signal.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

public extension Signal where Value == Result<UpdatedValue, UpdatedValueError>, Error == NoError {

	func filter(peripheral: CBPeripheral) -> Signal<Result<UpdatedValue, UpdatedValueError>, NoError> {

		return self.filter { $0.isIncluded(peripheral: peripheral) }
	}

	func filter(characteristic: CBCharacteristic) -> Signal<Result<UpdatedValue, UpdatedValueError>, NoError> {

		return self.filter { $0.isIncluded(characteristic: characteristic) }
	}

	func filter(characteristic: CBUUID) -> Signal<Result<UpdatedValue, UpdatedValueError>, NoError> {

		return self.filter { $0.isIncluded(characteristic: characteristic) }
	}

	func filter(characteristic: String) -> Signal<Result<UpdatedValue, UpdatedValueError>, NoError> {

		return self.filter { $0.isIncluded(characteristic: characteristic) }
	}

	func dematerializeValue() -> Signal<UpdatedValue, UpdatedValueError> {
		return self.promoteError(UpdatedValueError.self)
			.flatMap(.latest) { (result:Result<UpdatedValue, UpdatedValueError>) -> Signal<UpdatedValue, UpdatedValueError> in
				switch result {
				case .success(let value):
					return Signal<UpdatedValue, UpdatedValueError> { observer, _ in
						observer.send(value: value)
						observer.sendCompleted()
					}

				case .failure(let error):
					return Signal<UpdatedValue, UpdatedValueError> { observer, _ in
						observer.send(error: error)
						observer.sendCompleted()
					}
				}
		}
	}
}
