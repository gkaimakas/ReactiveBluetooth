//
//  DidDiscoverCharacteristicsEvent.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 24/10/2017.
//

import CoreBluetooth
import Foundation

class DidDiscoverCharacteristicsEvent: PeripheralEvent {
	let service: CBService

	init?(event: PeripheralDelegateEvent) {
		switch event {
		case .didDiscoverCharacteristics(peripheral: let peripheral, service: let service, error: let error):
			self.service = service
			super.init(peripheral: peripheral, error: error)
		default:
			return nil
		}
	}
}
