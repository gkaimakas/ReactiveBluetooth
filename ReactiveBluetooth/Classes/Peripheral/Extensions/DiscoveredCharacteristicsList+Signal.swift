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

public extension Signal where Value == Result<DiscoveredCharacteristicsList, DiscoveredCharacteristicError>, Error == NoError {

	func filter(peripheral: CBPeripheral) -> Signal<Result<DiscoveredCharacteristicsList, DiscoveredCharacteristicError>, NoError> {

		return self.filter { $0.isIncluded(peripheral: peripheral) }
	}

	func filter(service: CBService) -> Signal<Result<DiscoveredCharacteristicsList, DiscoveredCharacteristicError>, NoError> {

		return self.filter { $0.isIncluded(service: service) }
	}

	func filter(service: CBUUID) -> Signal<Result<DiscoveredCharacteristicsList, DiscoveredCharacteristicError>, NoError> {

		return self.filter { $0.isIncluded(service: service) }
	}

	func filter(service: String) -> Signal<Result<DiscoveredCharacteristicsList, DiscoveredCharacteristicError>, NoError> {

		return self.filter { $0.isIncluded(service: service) }
	}

	func dematerializeValue() -> Signal<DiscoveredCharacteristicsList, DiscoveredCharacteristicError> {
		return self.promoteError(DiscoveredCharacteristicError.self)
			.flatMap(.latest) { (result:Result<DiscoveredCharacteristicsList, DiscoveredCharacteristicError>) -> Signal<DiscoveredCharacteristicsList, DiscoveredCharacteristicError> in
				switch result {
				case .success(let value):
					return Signal<DiscoveredCharacteristicsList, DiscoveredCharacteristicError> { observer, _ in
						observer.send(value: value)
						observer.sendCompleted()
					}

				case .failure(let error):
					return Signal<DiscoveredCharacteristicsList, DiscoveredCharacteristicError> { observer, _ in
						observer.send(error: error)
						observer.sendCompleted()
					}
				}
		}
	}
}
