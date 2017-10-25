//
//  CentralBaseEvent.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 25/10/2017.
//

import CoreBluetooth
import Foundation

internal class CentralBaseEvent {
	let central: CBCentralManager

	init(central: CBCentralManager) {
		self.central = central
	}
}
