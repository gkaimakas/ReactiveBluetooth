//
//  DidUpdateNameEvent.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 24/10/2017.
//

import CoreBluetooth
import Foundation

internal class DidUpdateNameEvent: BasePeripheralEvent {
	init?(event: PeripheralDelegateEvent) {
		switch event {
		case .didUpdateName(peripheral: let peripheral):
			super.init(peripheral: peripheral)
		default:
			return nil
		}
	}
}
