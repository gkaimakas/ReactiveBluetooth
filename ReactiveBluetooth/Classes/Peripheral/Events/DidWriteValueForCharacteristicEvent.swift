//
//  DidWriteValueEvent.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 24/10/2017.
//

import CoreBluetooth
import Foundation

internal class DidWriteValueForCharacteristicEvent: PeripheralEvent {
	let characteristic: CBCharacteristic

	init?(event: PeripheralDelegateEvent) {
		switch event {
		case .didWriteValueForCharacteristic(peripheral: let peripheral, characteristic: let characteristic, error: let error):
			self.characteristic = characteristic
			super.init(peripheral: peripheral, error: error)
		default:
			return nil
		}
	}
}
