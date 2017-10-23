//
//  CBCentral+Signal.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 23/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

public extension Signal where Value: CBCentralManager {
	func filter(central: CBCentralManager) -> Signal<Value, Error> {
		return filter { $0 == central }
	}
}
