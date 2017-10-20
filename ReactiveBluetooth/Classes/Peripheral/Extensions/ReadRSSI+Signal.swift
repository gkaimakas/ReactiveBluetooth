//
//  ReadRSSI+Signal.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

public extension Signal where Value == Result<ReadRSSI, ReadRSSIError>, Error == NoError {

	func filter(peripheral: CBPeripheral) -> Signal<Result<ReadRSSI, ReadRSSIError>, NoError> {

		return self.filter { $0.isIncluded(peripheral: peripheral) }
	}

	func dematerializeValue() -> Signal<ReadRSSI, ReadRSSIError> {
		return self.promoteError(ReadRSSIError.self)
			.flatMap(.latest) { (result:Result<ReadRSSI, ReadRSSIError>) -> Signal<ReadRSSI, ReadRSSIError> in
				switch result {
				case .success(let value):
					return Signal<ReadRSSI, ReadRSSIError> { observer, _ in
						observer.send(value: value)
						observer.sendCompleted()
					}

				case .failure(let error):
					return Signal<ReadRSSI, ReadRSSIError> { observer, _ in
						observer.send(error: error)
						observer.sendCompleted()
					}
				}
		}
	}
}
