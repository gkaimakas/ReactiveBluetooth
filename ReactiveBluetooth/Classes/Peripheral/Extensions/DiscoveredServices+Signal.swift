//
//  DiscoveredService+Signal.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

public extension Signal where Value == Result<DiscoveredServicesList, DiscoveredServiceError>, Error == NoError {

	func filter(peripheral: CBPeripheral) -> Signal<Result<DiscoveredServicesList, DiscoveredServiceError>, NoError> {

		return self.filter { $0.isIncluded(peripheral: peripheral) }
	}

	func dematerializeValue() -> Signal<DiscoveredServicesList, DiscoveredServiceError> {
		return self.promoteError(DiscoveredServiceError.self)
			.flatMap(.latest) { (result:Result<DiscoveredServicesList, DiscoveredServiceError>) -> Signal<DiscoveredServicesList, DiscoveredServiceError> in
				switch result {
				case .success(let value):
					return Signal<DiscoveredServicesList, DiscoveredServiceError> { observer, _ in
						observer.send(value: value)
						observer.sendCompleted()
					}

				case .failure(let error):
					return Signal<DiscoveredServicesList, DiscoveredServiceError> { observer, _ in
						observer.send(error: error)
						observer.sendCompleted()
					}
				}
		}
	}
}
