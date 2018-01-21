//
//  WillRestoreStateEvent.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 25/10/2017.
//

import CoreBluetooth
import Foundation

class WillRestoreStateEvent: CentralBaseEvent {
    let options: [CentralManager.StateRestorationOption]

	init?(event: CentralManagerDelegateEvent){
		switch event {
		case .willRestoreState(central: let central, dict: let dict):
			options = CentralManager.StateRestorationOption.parse(dictionary: dict, central: CentralManager(central: central))
			super.init(central: central)
		default:
			return nil
		}
	}
}
