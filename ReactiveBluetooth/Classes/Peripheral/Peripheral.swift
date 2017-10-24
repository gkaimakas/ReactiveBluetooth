//
//  Peripheral.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 24/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

public class Peripheral {
	private let peripheral: CBPeripheral
	private let peripheralDelegate: PeripheralObserver

	internal init(peripheral: CBPeripheral) {
		self.peripheral = peripheral
		self.peripheralDelegate = PeripheralObserver()
	}

	public func discoverServices(_ servicesUUIDs: [CBUUID]?) -> SignalProducer<Service, NSError> {

		let signal = peripheralDelegate
			.events
			.filter { $0.filter(peripheral: self.peripheral) }
			.filter { $0.isDidDiscoverServicesEvent() }
			.map { DidDiscoverServicesEvent(event: $0) }
			.skipNil()

		let resultProducer = SignalProducer(signal)
			.take(first: 1)
			.flatMap(.latest) { event -> SignalProducer<Service, NSError> in
				if let error = event.error as NSError? {
					return SignalProducer.init(error: error)
				}

				if let services = event.peripheral.services {
					let result = services
						.map { Service(peripheral: self.peripheral,
						               service: $0,
						               delegate: self.peripheralDelegate)
							
					}

					return SignalProducer.init(result)
				}

				return SignalProducer.empty
			}

		let producer = SignalProducer<Void, NSError>.init {
				self.peripheral.discoverServices(servicesUUIDs)
			}
			.then(resultProducer)

		return producer
	}

	public func readRSSI() -> SignalProducer<NSNumber, NSError> {

		let signal = peripheralDelegate
			.events
			.filter { $0.filter(peripheral: self.peripheral) }
			.filter { $0.isDidReadRSSIEvent() }
			.map { DidReadRSSIEvent(event: $0) }
			.skipNil()

		let resultProducer = SignalProducer(signal)
			.take(first: 1)
			.flatMap(.latest) { event -> SignalProducer<NSNumber, NSError> in
				if let error = event.error as NSError? {
					return SignalProducer.init(error: error)
				}

				return SignalProducer.init(value: event.RSSI)
			}

		let producer = SignalProducer<Void, NSError>.init {
				self.peripheral.readRSSI()
			}
			.then(resultProducer)

		return producer
	}
	
}
