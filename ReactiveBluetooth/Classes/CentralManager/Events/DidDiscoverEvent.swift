//
//  DidDiscoverEvent.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 25/10/2017.
//

import CoreBluetooth
import Foundation

class DidDiscoverEvent: CentralBaseEvent {
	let peripheral: CBPeripheral
	let advertismentData: [String: Any]
	let RSSI: NSNumber
	
	init?(event: CentralManagerDelegateEvent) {
		switch event {
		case .didDiscover(central: let central,
		                  peripheral: let peripheral,
		                  advertismentData: let advertismentData,
		                  RSSI: let RSSI):
			self.peripheral = peripheral
			self.advertismentData = advertismentData
			self.RSSI = RSSI
			super.init(central: central)
		default:
			return nil
		}
	}
}
