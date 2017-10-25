//
//  DidUpdateStateEvent.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 25/10/2017.
//

import CoreBluetooth
import Foundation

internal class DidUpdateStateEvent: CentralBaseEvent {
	init?(event: CentralManagerDelegateEvent) {
		switch event {
		case .didUpdateState(central: let central):
			super.init(central: central)
		default:
			return nil
		}
	}
}
