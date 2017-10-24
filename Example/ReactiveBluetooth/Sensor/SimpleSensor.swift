//
//  SimpleSensor.swift
//  ReactiveBluetooth_Example
//
//  Created by George Kaimakas on 23/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import CoreBluetooth
import Foundation
import ReactiveBluetooth
import ReactiveSwift
import Result

class SimpleSensor {
	let central: CBCentralManager
	let centralObserver: CentralManagerObserver
	let peripheralObserver: PeripheralObserver

	init() {
		peripheralObserver = PeripheralObserver()
		centralObserver = CentralManagerObserver()

		central = CBCentralManager(delegate: centralObserver, queue: nil)

	
	}
}
