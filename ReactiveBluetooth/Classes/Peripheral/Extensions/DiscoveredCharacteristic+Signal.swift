//
//  DiscoveredCharacteristic+Signal.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

public extension Signal where Value == Result<DiscoveredCharacteristic, DiscoveredCharacteristicError>, Error == NoError {

	func filter(peripheral: CBPeripheral) -> Signal<Result<DiscoveredCharacteristic, DiscoveredCharacteristicError>, NoError> {

		return self.filter { $0.isIncluded(peripheral: peripheral) }
	}

	func filter(service: CBService) -> Signal<Result<DiscoveredCharacteristic, DiscoveredCharacteristicError>, NoError> {

		return self.filter { $0.isIncluded(service: service) }
	}

	func filter(service: CBUUID) -> Signal<Result<DiscoveredCharacteristic, DiscoveredCharacteristicError>, NoError> {

		return self.filter { $0.isIncluded(service: service) }
	}

	func filter(service: String) -> Signal<Result<DiscoveredCharacteristic, DiscoveredCharacteristicError>, NoError> {

		return self.filter { $0.isIncluded(service: service) }
	}

	func dematerializeValue() -> Signal<DiscoveredCharacteristic, DiscoveredCharacteristicError> {
		return self.promoteError(DiscoveredCharacteristicError.self)
			.flatMap(.latest) { (result:Result<DiscoveredCharacteristic, DiscoveredCharacteristicError>) -> Signal<DiscoveredCharacteristic, DiscoveredCharacteristicError> in
				switch result {
				case .success(let value):
					return Signal<DiscoveredCharacteristic, DiscoveredCharacteristicError> { observer, _ in
						observer.send(value: value)
						observer.sendCompleted()
					}

				case .failure(let error):
					return Signal<DiscoveredCharacteristic, DiscoveredCharacteristicError> { observer, _ in
						observer.send(error: error)
						observer.sendCompleted()
					}
				}
		}
	}
}
