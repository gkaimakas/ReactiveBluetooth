//
//  UpdatedNotificationState+Signal.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

public extension Signal where Value == Result<UpdatedNotificationState, UpdatedNotificationStateError>, Error == NoError {

	func filter(peripheral: CBPeripheral) -> Signal<Result<UpdatedNotificationState, UpdatedNotificationStateError>, NoError> {

		return self.filter { $0.isIncluded(peripheral: peripheral) }
	}

	func filter(characteristic: CBCharacteristic) -> Signal<Result<UpdatedNotificationState, UpdatedNotificationStateError>, NoError> {

		return self.filter { $0.isIncluded(characteristic: characteristic) }
	}

	func filter(characteristic: CBUUID) -> Signal<Result<UpdatedNotificationState, UpdatedNotificationStateError>, NoError> {

		return self.filter { $0.isIncluded(characteristic: characteristic) }
	}

	func filter(characteristic: String) -> Signal<Result<UpdatedNotificationState, UpdatedNotificationStateError>, NoError> {

		return self.filter { $0.isIncluded(characteristic: characteristic) }
	}

	func dematerializeValue() -> Signal<UpdatedNotificationState, UpdatedNotificationStateError> {
		return self.promoteError(UpdatedNotificationStateError.self)
			.flatMap(.latest) { (result:Result<UpdatedNotificationState, UpdatedNotificationStateError>) -> Signal<UpdatedNotificationState, UpdatedNotificationStateError> in
				switch result {
				case .success(let value):
					return Signal<UpdatedNotificationState, UpdatedNotificationStateError> { observer, _ in
						observer.send(value: value)
						observer.sendCompleted()
					}

				case .failure(let error):
					return Signal<UpdatedNotificationState, UpdatedNotificationStateError> { observer, _ in
						observer.send(error: error)
						observer.sendCompleted()
					}
				}
		}
	}
}
