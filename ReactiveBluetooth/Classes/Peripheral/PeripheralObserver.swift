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

public class PeripheralObserver: NSObject {

	public let events: Signal<PeripheralDelegateEvent, NoError>
	public let eventsObserver: Signal<PeripheralDelegateEvent, NoError>.Observer

	public override init() {
		(events, eventsObserver) = Signal.pipe()

		super.init()
	}
}

//MARK:- CBPeripheralDelegate

extension PeripheralObserver: CBPeripheralDelegate {

	public func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
		eventsObserver.send(value: .didUpdateName(peripheral: peripheral))
	}

	public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
		eventsObserver.send(value: .didReadRSSI(peripheral: peripheral,
		                                        RSSI: RSSI,
		                                        error: error))
	}

	public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		eventsObserver.send(value: .didDiscoverServices(peripheral: peripheral,
		                                                error: error))
	}

	public func peripheral(_ peripheral: CBPeripheral,
	                       didDiscoverCharacteristicsFor service: CBService,
	                       error: Error?) {
		eventsObserver.send(value: .didDiscoverCharacteristics(peripheral: peripheral,
		                                                       service: service,
		                                                       error: error))
	}

	public func peripheral(_ peripheral: CBPeripheral,
	                       didUpdateNotificationStateFor characteristic: CBCharacteristic,
	                       error: Error?) {

		eventsObserver.send(value: .didUpdateNotificationState(peripheral: peripheral,
		                                                       characteristic: characteristic,
		                                                       error: error))
	}

	public func peripheral(_ peripheral: CBPeripheral,
	                       didWriteValueFor characteristic: CBCharacteristic,
	                       error: Error?) {

		eventsObserver.send(value: .didWriteValue(peripheral: peripheral,
		                                          characteristic: characteristic,
		                                          error: error))

	}

	public func peripheral(_ peripheral: CBPeripheral,
	                       didUpdateValueFor characteristic: CBCharacteristic,
	                       error: Error?) {
		
		eventsObserver.send(value: .didUpdateValue(peripheral: peripheral,
		                                           characteristic: characteristic,
		                                           error: error))

	}
}

extension PeripheralObserver: PeripheralDelegate {
}
