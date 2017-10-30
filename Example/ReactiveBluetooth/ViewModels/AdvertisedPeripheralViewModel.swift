//
//  DiscoveredPeripheralViewModel.swift
//  ReactiveBluetooth_Example
//
//  Created by George Kaimakas on 30/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import CoreBluetooth
import Foundation
import ReactiveBluetooth
import ReactiveCocoa
import ReactiveSwift
import Result

class AdvertisedPeripheralViewModel {
	let peripheral: DiscoveredPeripheral

	let state: Property<CBPeripheralState>
	let advertismentData: Property<[String: Any]>
	let RSSI: Property<NSNumber>

	let toggleConnection: Action<Void, Void, NSError>

	init(peripheral: DiscoveredPeripheral) {
		self.peripheral = peripheral
		self.state = peripheral.peripheral.state
		self.advertismentData = peripheral.advertismentData
		self.RSSI = peripheral.RSSI

		self.toggleConnection = Action { _ -> SignalProducer<Void, NSError> in
			if peripheral.peripheral.state.value == CBPeripheralState.connected ||
				peripheral.peripheral.state.value == CBPeripheralState.connecting {
				return peripheral
					.peripheral
					.disconnect()
					.map { _ in () }
					.timeout(after: 10,
					         raising: NSError(domain: "com.gkaimakas.ReactiveBluetooth.Example",
					                          code: 1,
					                          userInfo: [
												NSLocalizedDescriptionKey: "Disconnection timed out"
								]), on: QueueScheduler.main)
			}

			if peripheral.peripheral.state.value == CBPeripheralState.disconnected {
				return peripheral
					.peripheral
					.connect()
					.map { _ in () }
					.timeout(after: 10,
					         raising: NSError(domain: "com.gkaimakas.ReactiveBluetooth.Example",
					                          code: 2,
					                          userInfo: [
												NSLocalizedDescriptionKey: "Cconnection timed out"
								]), on: QueueScheduler.main)
					.flatMapError({ error -> SignalProducer<Void, NSError> in
						return peripheral
							.peripheral
							.disconnect()
							.map { _ in () }
					})

			}

			return SignalProducer.empty
		}
	}
}

extension AdvertisedPeripheralViewModel: Hashable {
	static func ==(lhs: AdvertisedPeripheralViewModel, rhs: AdvertisedPeripheralViewModel) -> Bool {
		return lhs.peripheral == rhs.peripheral
	}
	
	var hashValue: Int {
		return peripheral.hashValue
	}
}
