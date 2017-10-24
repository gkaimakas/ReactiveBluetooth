//
//  PeripheralDelegateEvent.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 24/10/2017.
//

import CoreBluetooth
import Foundation

public enum PeripheralDelegateEvent {
	case didUpdateName(peripheral: CBPeripheral)
	case didReadRSSI(peripheral: CBPeripheral, RSSI: NSNumber, error: Error?)
	case didDiscoverServices(peripheral: CBPeripheral, error: Error?)
	case didDiscoverCharacteristics(peripheral: CBPeripheral, service: CBService, error: Error?)
	case didUpdateNotificationState(peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?)
	case didWriteValue(peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?)
	case didUpdateValue(peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?)

	public func filter(peripheral: CBPeripheral) -> Bool {
		switch self {
		case .didUpdateName(peripheral: let _peripheral):
			return peripheral == _peripheral
		case .didReadRSSI(peripheral: let _peripheral, RSSI: _, error: _):
			return peripheral == _peripheral
		case .didDiscoverServices(peripheral: let _peripheral, error: _):
			return peripheral == _peripheral
		case .didDiscoverCharacteristics(peripheral: let _peripheral, service: _, error: _):
			return peripheral == _peripheral
		case .didUpdateNotificationState(peripheral: let _peripheral, characteristic: _, error: _):
			return peripheral == _peripheral
		case .didWriteValue(peripheral: let _peripheral, characteristic: _, error: _):
			return peripheral == _peripheral
		case .didUpdateValue(peripheral: let _peripheral, characteristic: _, error: _):
			return peripheral == _peripheral
		}
	}

	public func filter(service: CBService) -> Bool {
		switch self {
		case .didDiscoverCharacteristics(peripheral: _, service: let _service, error: _):
			return service == _service
		default:
			return false
		}
	}

	public func filter(service: CBUUID) -> Bool {
		switch self {
		case .didDiscoverCharacteristics(peripheral: _, service: let _service, error: _):
			return service.isEqual(_service.uuid)
		default:
			return false
		}
	}

	public func filter(service: String) -> Bool {
		switch self {
		case .didDiscoverCharacteristics(peripheral: _, service: let _service, error: _):
			return service == _service.uuid.uuidString
		default:
			return false
		}
	}

	public func filter(characteristic: CBCharacteristic) -> Bool {
		switch self {
		case .didUpdateNotificationState(peripheral: _, characteristic: let _characteristic, error: _):
			return characteristic == _characteristic
		case .didWriteValue(peripheral: _, characteristic: let _characteristic, error: _):
			return characteristic == _characteristic
		case .didUpdateValue(peripheral: _, characteristic: let _characteristic, error: _):
			return characteristic == _characteristic
		default:
			return false
		}
	}

	public func filter(characteristic: CBUUID) -> Bool {
		switch self {
		case .didUpdateNotificationState(peripheral: _, characteristic: let _characteristic, error: _):
			return characteristic.isEqual(_characteristic.uuid)
		case .didWriteValue(peripheral: _, characteristic: let _characteristic, error: _):
			return characteristic.isEqual(_characteristic.uuid)
		case .didUpdateValue(peripheral: _, characteristic: let _characteristic, error: _):
			return characteristic.isEqual(_characteristic.uuid)
		default:
			return false
		}
	}

	public func filter(characteristic: String) -> Bool {
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

	public func isDidUpdateNameEvent() -> Bool {
		switch self {
		case .didUpdateName(peripheral: _):
			return true
		default:
			return false
		}
	}

	public func isDidReadRSSIEvent() -> Bool {
		switch self {
		case .didReadRSSI(peripheral: _, RSSI: _, error: _):
			return true
		default:
			return false
		}
	}

	public func isDidDiscoverServicesNameEvent() -> Bool {
		switch self {
		case .didDiscoverServices(peripheral: _, error: _):
			return true
		default:
			return false
		}
	}

	public func isDidDiscoverCharacteristicsNameEvent() -> Bool {
		switch self {
		case .didDiscoverCharacteristics(peripheral: _, service: _, error: _):
			return true
		default:
			return false
		}
	}

	public func isDidUpdateNotificationStateEvent() -> Bool {
		switch self {
		case .didUpdateNotificationState(peripheral: _, characteristic: _, error: _):
			return true
		default:
			return false
		}
	}

	public func isDidWriteValueEvent() -> Bool {
		switch self {
		case .didWriteValue(peripheral: _, characteristic: _, error: _):
			return true
		default:
			return false
		}
	}

	public func isDidUpdateValueEvent() -> Bool {
		switch self {
		case .didUpdateName(peripheral: _):
			return true
		default:
			return false
		}
	}
}
