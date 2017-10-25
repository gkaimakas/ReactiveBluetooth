//
//  WillRestoreStateEvent.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 25/10/2017.
//

import CoreBluetooth
import Foundation

internal class WillRestoreStateEvent: CentralBaseEvent {
	let dict: [String: Any]

	init?(event: CentralManagerDelegateEvent){
		switch event {
		case .willRestoreState(central: let central, dict: let dict):
			self.dict = dict
			super.init(central: central)
		default:
			return nil
		}
	}
}
