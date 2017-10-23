//
//  CentralManagerProvider+Signal.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 23/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

public extension Signal where Value: CentralManagerProvider {
	func filter(central: CBCentralManager) -> Signal<Value, Error> {
		return self.filter { $0.central == central }
	}
}
