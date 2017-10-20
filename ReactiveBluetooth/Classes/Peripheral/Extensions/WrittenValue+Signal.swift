//
//  WrittenValue+Signal.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

public extension Signal where Value == Result<WrittenValue, WrittenValueError>, Error == NoError {

	func filter(peripheral: CBPeripheral) -> Signal<Result<WrittenValue, WrittenValueError>, NoError> {

		return self.filter { $0.isIncluded(peripheral: peripheral) }
	}

	func filter(characteristic: CBCharacteristic) -> Signal<Result<WrittenValue, WrittenValueError>, NoError> {

		return self.filter { $0.isIncluded(characteristic: characteristic) }
	}

	func filter(characteristic: CBUUID) -> Signal<Result<WrittenValue, WrittenValueError>, NoError> {

		return self.filter { $0.isIncluded(characteristic: characteristic) }
	}

	func filter(characteristic: String) -> Signal<Result<WrittenValue, WrittenValueError>, NoError> {

		return self.filter { $0.isIncluded(characteristic: characteristic) }
	}

	func dematerializeValue() -> Signal<WrittenValue, WrittenValueError> {
		return self.promoteError(WrittenValueError.self)
			.flatMap(.latest) { (result:Result<WrittenValue, WrittenValueError>) -> Signal<WrittenValue, WrittenValueError> in
				switch result {
				case .success(let value):
					return Signal<WrittenValue, WrittenValueError> { observer, _ in
						observer.send(value: value)
						observer.sendCompleted()
					}

				case .failure(let error):
					return Signal<WrittenValue, WrittenValueError> { observer, _ in
						observer.send(error: error)
						observer.sendCompleted()
					}
				}
		}
	}
}
