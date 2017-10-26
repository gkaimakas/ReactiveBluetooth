//
//  DidDiscoverDescriptorsEvent.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 26/10/2017.
//

import CoreBluetooth
import Foundation

class DidDiscoverDescriptorsEvent: PeripheralEvent {
	let characteristic: CBCharacteristic

	init?(event: PeripheralDelegateEvent) {
		switch event {
		case let .didDiscoverDescriptors(peripheral: peripheral, characteristic: characteristic, error: error):
			self.characteristic = characteristic
			super.init(peripheral: peripheral, error: error)
		default:
			return nil
		}
	}
}
