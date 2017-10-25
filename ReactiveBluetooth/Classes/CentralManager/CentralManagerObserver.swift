//
//  CentralManagerObserver.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 25/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

class CentralManagerObserver: NSObject {
	let events: Signal<CentralManagerDelegateEvent, NoError>
	fileprivate let eventsObserver: Signal<CentralManagerDelegateEvent, NoError>.Observer

	override init() {
		(events, eventsObserver) = Signal.pipe()
		super.init()
	}
}

extension CentralManagerObserver: CBCentralManagerDelegate {
	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		eventsObserver.send(value: .didUpdateState(central: central))
	}

	func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
		eventsObserver.send(value: .willRestoreState(central: central, dict: dict))
	}

	func centralManager(_ central: CBCentralManager,
	                    didDiscover peripheral: CBPeripheral,
	                    advertisementData: [String : Any],
	                    rssi RSSI: NSNumber) {
		eventsObserver.send(value: .didDiscover(central: central,
		                                        peripheral: peripheral,
		                                        advertismentData: advertisementData,
		                                        RSSI: RSSI))
	}

	func centralManager(_ central: CBCentralManager,
	                    didConnect peripheral: CBPeripheral) {

		eventsObserver.send(value: .didConnect(central: central,
		                                       peripheral: peripheral,
		                                       error: nil))
	}

	func centralManager(_ central: CBCentralManager,
	                    didFailToConnect peripheral: CBPeripheral,
	                    error: Error?) {

		eventsObserver.send(value: .didConnect(central: central,
		                                       peripheral: peripheral,
		                                       error: error))
	}

	func centralManager(_ central: CBCentralManager,
	                    didDisconnectPeripheral peripheral: CBPeripheral,
	                    error: Error?) {

		eventsObserver.send(value: .didDisconnect(central: central,
		                                          peripheral: peripheral,
		                                          error: error))
		
	}
}
