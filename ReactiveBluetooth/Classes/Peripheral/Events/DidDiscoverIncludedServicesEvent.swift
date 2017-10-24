//
//  DidDiscoverIncludedServicesEvent.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 24/10/2017.
//

import CoreBluetooth
import Foundation

internal class DidDiscoverIncludedServicesEvent: PeripheralEvent {
	let service: CBService
	init? (event: PeripheralDelegateEvent) {
		switch event {
		case .didDiscoverIncludedServices(peripheral: let _peripheral, service: let _service, error: let _error):
			self.service = _service
			super.init(peripheral: _peripheral, error: _error)
		default:
			return nil
		}
	}
}
