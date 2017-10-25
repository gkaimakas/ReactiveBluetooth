//
//  Peripheral.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 24/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveCocoa
import ReactiveSwift
import Result

public class Peripheral: NSObject {
	let peripheral: CBPeripheral
	private let central: CentralManager
	private let peripheralDelegate: PeripheralObserver

	public let state: Property<CBPeripheralState>

	internal init(peripheral: CBPeripheral,
	              central: CentralManager
		) {

		self.peripheral = peripheral
		self.peripheralDelegate = PeripheralObserver()
		self.central = central
		self.peripheral.delegate = self.peripheralDelegate

		self.state = Property<CBPeripheralState>(initial: CBPeripheralState.disconnected,
		                                         then: peripheral
													.reactive
													.producer(forKeyPath: #keyPath(CBPeripheral.state))
													.skipNil()
													.map { CBPeripheralState.init(rawValue: $0 as! Int) }
													.skipNil()
			)
			.skipRepeats()




		super.init()
	}

	public func connect(options: [String: Any]? = nil) -> SignalProducer<Peripheral, NSError> {
		return central.connect(to: self, options: options)
	}

	public func disconnect() -> SignalProducer<Peripheral, NSError> {
		return central.cancelPeripheralConnection(from: self)
	}

	/// Discovers services
	public func discoverServices(_ servicesUUIDs: [CBUUID]? = nil) -> SignalProducer<Service, NSError> {

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
						.map { Service(peripheral: self,
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

	/// Reads the peripheral's RSSI
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
