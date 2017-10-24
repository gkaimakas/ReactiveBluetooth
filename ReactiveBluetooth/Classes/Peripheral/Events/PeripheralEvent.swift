//
//  PeripheralEvent.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 24/10/2017.
//

import CoreBluetooth
import Foundation

internal class PeripheralEvent: BasePeripheralEvent {
	let error: Error?

	init(peripheral: CBPeripheral,
	            error: Error?) {

		self.error = error
		super.init(peripheral: peripheral)
	}
}
