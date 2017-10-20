//
//  CharacteristicProvider+Signal.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

public extension Signal where Value: ResultProtocol, Value.Value: CharacteristicProvider, Value.Error: CharacteristicProviderError, Error == NoError {

	func filter(characteristic: CBCharacteristic) -> Signal<Value, Error> {
		return filter { $0.isIncluded(characteristic: characteristic) }
	}

	func filter(characteristic: CBUUID) -> Signal<Value, Error> {
		return filter { $0.isIncluded(characteristic: characteristic) }
	}

	func filter(characteristic: String) -> Signal<Value, Error> {
		return filter { $0.isIncluded(characteristic: characteristic) }
	}
}
