//
//  DidDiscoverServicesEvent.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 24/10/2017.
//

import CoreBluetooth
import Foundation

internal class DidDiscoverServicesEvent: PeripheralEvent {
	init? (event: PeripheralDelegateEvent) {
		switch event {
		case .didDiscoverServices(peripheral: let peripheral, error: let error):
			super.init(peripheral: peripheral, error: error)
		default:
			return nil
		}
	}
}
