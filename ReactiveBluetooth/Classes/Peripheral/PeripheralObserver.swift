//
//  PeripheralObserver.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 19/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

class PeripheralObserver: NSObject {
	let events: Signal<PeripheralDelegateEvent, NoError>
	fileprivate let eventsObserver: Signal<PeripheralDelegateEvent, NoError>.Observer

	override init() {
		(events, eventsObserver) = Signal.pipe()
		super.init()
	}
}

//MARK:- CBPeripheralDelegate

extension PeripheralObserver: CBPeripheralDelegate {

	func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
		eventsObserver.send(value: .didUpdateName(peripheral: peripheral))
	}

	func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
		eventsObserver.send(value: .didReadRSSI(peripheral: peripheral,
		                                        RSSI: RSSI,
		                                        error: error))
	}

	func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		eventsObserver.send(value: .didDiscoverServices(peripheral: peripheral,
		                                                error: error))
	}

	func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
		eventsObserver.send(value: .didDiscoverIncludedServices(peripheral: peripheral,
		                                                        service: service,
		                                                        error: error))
	}

	func peripheral(_ peripheral: CBPeripheral,
	                       didDiscoverCharacteristicsFor service: CBService,
	                       error: Error?) {
		eventsObserver.send(value: .didDiscoverCharacteristics(peripheral: peripheral,
		                                                       service: service,
		                                                       error: error))
	}

	func peripheral(_ peripheral: CBPeripheral,
	                       didUpdateNotificationStateFor characteristic: CBCharacteristic,
	                       error: Error?) {

		eventsObserver.send(value: .didUpdateNotificationState(peripheral: peripheral,
		                                                       characteristic: characteristic,
		                                                       error: error))
	}

	func peripheral(_ peripheral: CBPeripheral,
	                       didWriteValueFor characteristic: CBCharacteristic,
	                       error: Error?) {

		eventsObserver.send(value: .didWriteValue(peripheral: peripheral,
		                                          characteristic: characteristic,
		                                          error: error))

	}

	func peripheral(_ peripheral: CBPeripheral,
	                       didUpdateValueFor characteristic: CBCharacteristic,
	                       error: Error?) {
		
		eventsObserver.send(value: .didUpdateValue(peripheral: peripheral,
		                                           characteristic: characteristic,
		                                           error: error))

	}
}
