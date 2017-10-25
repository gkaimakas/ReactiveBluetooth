//
//  PeripheralDelegateEvent.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 24/10/2017.
//

import CoreBluetooth
import Foundation

internal enum PeripheralDelegateEvent {
	case didUpdateName(peripheral: CBPeripheral)
	case didReadRSSI(peripheral: CBPeripheral, RSSI: NSNumber, error: Error?)
	case didDiscoverServices(peripheral: CBPeripheral, error: Error?)
	case didDiscoverIncludedServices(peripheral: CBPeripheral, service: CBService, error: Error?)
	case didDiscoverCharacteristics(peripheral: CBPeripheral, service: CBService, error: Error?)
	case didUpdateNotificationState(peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?)
	case didWriteValue(peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?)
	case didUpdateValue(peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?)

	func filter(peripheral: CBPeripheral) -> Bool {
		switch self {
		case .didUpdateName(peripheral: let _peripheral):
			return peripheral.identifier == _peripheral.identifier
		case .didReadRSSI(peripheral: let _peripheral, RSSI: _, error: _):
			return peripheral.identifier == _peripheral.identifier
		case .didDiscoverServices(peripheral: let _peripheral, error: _):
			return peripheral.identifier == _peripheral.identifier
		case .didDiscoverIncludedServices(peripheral: let _peripheral, service: _, error: _):
			return peripheral.identifier == _peripheral.identifier
		case .didDiscoverCharacteristics(peripheral: let _peripheral, service: _, error: _):
			return peripheral.identifier == _peripheral.identifier
		case .didUpdateNotificationState(peripheral: let _peripheral, characteristic: _, error: _):
			return peripheral.identifier == _peripheral.identifier
		case .didWriteValue(peripheral: let _peripheral, characteristic: _, error: _):
			return peripheral.identifier == _peripheral.identifier
		case .didUpdateValue(peripheral: let _peripheral, characteristic: _, error: _):
			return peripheral.identifier == _peripheral.identifier
		}
	}

	func filter(service: CBService) -> Bool {
		return filter(service: service.uuid)
	}

	func filter(service: CBUUID) -> Bool {
		return filter(service: service.uuidString)
	}

	func filter(service: String) -> Bool {
		switch self {
		case .didDiscoverIncludedServices(peripheral: _, service: let _service, error: _):
			return service == _service.uuid.uuidString
		case .didDiscoverCharacteristics(peripheral: _, service: let _service, error: _):
			return service == _service.uuid.uuidString
		default:
			return false
		}
	}

	func filter(characteristic: CBCharacteristic) -> Bool {
		return filter(characteristic: characteristic.uuid)
	}

	func filter(characteristic: CBUUID) -> Bool {
		return filter(characteristic: characteristic.uuidString)
	}

	func filter(characteristic: String) -> Bool {
		switch self {
		case .didUpdateNotificationState(peripheral: _, characteristic: let _characteristic, error: _):
			return characteristic == _characteristic.uuid.uuidString
		case .didWriteValue(peripheral: _, characteristic: let _characteristic, error: _):
			return characteristic == _characteristic.uuid.uuidString
		case .didUpdateValue(peripheral: _, characteristic: let _characteristic, error: _):
			return characteristic == _characteristic.uuid.uuidString
		default:
			return false
		}
	}

	func isDidUpdateNameEvent() -> Bool {
		switch self {
		case .didUpdateName(peripheral: _):
			return true
		default:
			return false
		}
	}

	func isDidReadRSSIEvent() -> Bool {
		switch self {
		case .didReadRSSI(peripheral: _, RSSI: _, error: _):
			return true
		default:
			return false
		}
	}

	func isDidDiscoverServicesEvent() -> Bool {
		switch self {
		case .didDiscoverServices(peripheral: _, error: _):
			return true
		default:
			return false
		}
	}

	func isDidDiscoverIncludedServicesEvent() -> Bool {
		switch self {
		case .didDiscoverIncludedServices(peripheral: _, service: _, error: _):
			return true
		default:
			return false
		}
	}

	func isDidDiscoverCharacteristicsEvent() -> Bool {
		switch self {
		case .didDiscoverCharacteristics(peripheral: _, service: _, error: _):
			return true
		default:
			return false
		}
	}

	func isDidUpdateNotificationStateEvent() -> Bool {
		switch self {
		case .didUpdateNotificationState(peripheral: _, characteristic: _, error: _):
			return true
		default:
			return false
		}
	}

	func isDidWriteValueEvent() -> Bool {
		switch self {
		case .didWriteValue(peripheral: _, characteristic: _, error: _):
			return true
		default:
			return false
		}
	}

	func isDidUpdateValueEvent() -> Bool {
		switch self {
		case .didUpdateName(peripheral: _):
			return true
		default:
			return false
		}
	}
}
