//
//  DidReadRSSIEvent.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 24/10/2017.
//

import CoreBluetooth
import Foundation

internal class DidReadRSSIEvent: PeripheralEvent {
	let RSSI: NSNumber

	init(peripheral: CBPeripheral, RSSI: NSNumber, error: Error?) {
		self.RSSI = RSSI
		super.init(peripheral: peripheral, error: error)
	}

	convenience init?(event: PeripheralDelegateEvent) {
		switch event {
		case .didReadRSSI(peripheral: let peripheral, RSSI: let RSSI, error: let error):
			self.init(peripheral: peripheral,
			          RSSI: RSSI,
			          error: error)
		default:
			return nil
		}
	}

}
