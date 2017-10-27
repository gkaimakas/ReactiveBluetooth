//
//  AsyncHashTable.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 26/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveCocoa
import ReactiveSwift
import Result

class SyncDiscoveredPeripheralCache: NSObject {
	private let mapTable: NSMapTable<CBPeripheral, DiscoveredPeripheral>
	private let queue: DispatchQueue

	override init() {
		mapTable = NSMapTable<CBPeripheral, DiscoveredPeripheral>.weakToWeakObjects()
		queue = DispatchQueue(label: "com.gkaimakas.ReactiveBluetooth.SyncDiscoveredPeripheralCache", attributes: .concurrent)
	}

	func set(object: DiscoveredPeripheral) {
		queue.async(flags: .barrier) {
			self.mapTable.setObject(object, forKey: object.peripheral.peripheral)
		}
	}

	func object(for key: DiscoveredPeripheral) -> DiscoveredPeripheral? {
		return self.object(for: key.peripheral)
	}

	func object(for key: Peripheral) -> DiscoveredPeripheral? {
		return self.object(for: key.peripheral)
	}

	func object(for key: CBPeripheral) -> DiscoveredPeripheral? {
		var result: DiscoveredPeripheral?
		queue.sync {
			result = self.mapTable.object(forKey: key)
		}
		return result
	}
}

extension Reactive where Base == SyncDiscoveredPeripheralCache {
	var synchronizeDiscoveredPeripherals: BindingTarget<DiscoveredPeripheral> {
		return makeBindingTarget { (cache, update) in
			if let entry = cache.object(for: update) {
				entry._RSSI.value = update.RSSI.value
				entry._advertismentData.value = update.advertismentData.value
			} else {
				cache.set(object: update)
			}
		}
	}
}


