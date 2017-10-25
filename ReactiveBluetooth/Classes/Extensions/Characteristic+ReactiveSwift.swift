//
//  Characteristic+ReactiveSwift.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 25/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

public extension Signal where Value: Characteristic {
	func filter(characteristic: Characteristic) -> Signal<Value, Error> {
		return self.filter { $0.characteristic == characteristic.characteristic }
	}

	func filter(characteristic: CBUUID) -> Signal<Value, Error> {
		return self.filter { $0.uuid.value.isEqual(characteristic) }
	}

	func filter(characteristic: String) -> Signal<Value, Error> {
		return self.filter { $0.uuid.value.uuidString == characteristic }
	}
}

public extension SignalProducer where Value: Characteristic {
	func filter(characteristic: Characteristic) -> SignalProducer<Value, Error> {
		return self.lift { $0.filter(characteristic: characteristic) }
	}

	func filter(characteristic: CBUUID) -> SignalProducer<Value, Error> {
		return self.lift { $0.filter(characteristic: characteristic) }
	}

	func filter(characteristic: String) -> SignalProducer<Value, Error> {
		return self.lift { $0.filter(characteristic: characteristic) }
	}
}
