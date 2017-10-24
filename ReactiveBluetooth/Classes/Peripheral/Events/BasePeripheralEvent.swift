//
//  BasePeripheralEvent.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 24/10/2017.
//

import CoreBluetooth
import Foundation

internal class BasePeripheralEvent {
	let peripheral: CBPeripheral

	init(peripheral: CBPeripheral) {

		self.peripheral = peripheral
	}
}
