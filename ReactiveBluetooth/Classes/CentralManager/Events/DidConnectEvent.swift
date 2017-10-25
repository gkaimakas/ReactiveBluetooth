//
//  DidConnectEvent.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 25/10/2017.
//

import CoreBluetooth
import Foundation

class DidConnectEvent: CentralEvent {
	let peripheral: CBPeripheral

	init?(event: CentralManagerDelegateEvent) {
		switch event {
		case .didConnect(central: let central, peripheral: let peripheral, error: let error):
			self.peripheral = peripheral
			super.init(central: central, error: error)
		default:
			return nil
		}
	}
}
