//
//  DidUpdateNotificationStateEvent.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 24/10/2017.
//

import CoreBluetooth
import Foundation

internal class DidUpdateNotificationStateEvent: PeripheralEvent {
	let characteristic: CBCharacteristic

	init?(event: PeripheralDelegateEvent) {
		switch event {
		case .didUpdateNotificationState(peripheral: let peripgeral, characteristic: let characteristic, error: let error):
			self.characteristic = characteristic
			super.init(peripheral: peripgeral, error: error)
		default:
			return nil
		}
	}
}
