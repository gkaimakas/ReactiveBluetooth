//
//  PeripheralProvider+Signal.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

public extension Signal where Value: ResultProtocol, Value.Value: PeripheralProvider, Value.Error: PeripheralProviderError, Error == NoError {

	func filter(peripheral: CBPeripheral) -> Signal<Value, Error> {
		return filter { $0.isIncluded(peripheral: peripheral) }
	}
}
