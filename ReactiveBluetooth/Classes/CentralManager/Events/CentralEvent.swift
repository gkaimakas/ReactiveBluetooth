//
//  CentralEvent.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 25/10/2017.
//

import CoreBluetooth
import Foundation

internal class CentralEvent: CentralBaseEvent {
	let error: Error?

	init(central: CBCentralManager, error: Error?) {
		self.error = error
		super.init(central: central)
	}
}
