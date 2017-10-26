//
//  DiscoveredPeripheral.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 26/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveCocoa
import ReactiveSwift
import Result

public class DiscoveredPeripheral {
	let _advertismentData: MutableProperty<[String: Any]>
	let _RSSI: MutableProperty<NSNumber>

	public let peripheral: Peripheral
	public let advertismentData: Property<[String: Any]>
	public let RSSI: Property<NSNumber>

	init(peripheral: Peripheral, advertismentData: [String: Any], RSSI: NSNumber) {
		self.peripheral = peripheral
		self._advertismentData = MutableProperty(advertismentData)
		self._RSSI = MutableProperty(RSSI)

		self.advertismentData = Property(_advertismentData)
		self.RSSI = Property(_RSSI)
	}
}

// MARK: - Hashable

extension DiscoveredPeripheral: Hashable {
	public var hashValue: Int {
		return peripheral.peripheral.hashValue
	}

	public static func ==(lhs: DiscoveredPeripheral, rhs: DiscoveredPeripheral) -> Bool {
		return lhs.peripheral == rhs.peripheral
	}
}
