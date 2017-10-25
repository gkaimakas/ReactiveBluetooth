//
//  DidDisconnectEvent.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 25/10/2017.
//

import CoreBluetooth
import Foundation

class DidDisconnectEvent: CentralEvent {
	let peripheral: CBPeripheral

	init?(event: CentralManagerDelegateEvent) {
		switch event {
		case .didDisconnect(central: let central, peripheral: let peripheral, error: let error):
			self.peripheral = peripheral
			super.init(central: central, error: error)
		default:
			return nil
		}
	}
}
