//
//  CentralManagerDelegateEvent.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 25/10/2017.
//

import CoreBluetooth
import Foundation

enum CentralManagerDelegateEvent {
	case didUpdateState(central: CBCentralManager)
	case willRestoreState(central: CBCentralManager, dict: [String: Any])
	case didDiscover(central: CBCentralManager, peripheral: CBPeripheral, advertismentData: [String: Any], RSSI: NSNumber)
	case didConnect(central: CBCentralManager, peripheral: CBPeripheral, error: Error?)
	case didDisconnect(central: CBCentralManager, peripheral: CBPeripheral, error: Error?)

	func filter(central: CBCentralManager) -> Bool {
		switch self {
		case .didUpdateState(central: let _central):
			return central == _central
		case .willRestoreState(central: let _central, dict: _):
			return central == _central
		case .didDiscover(central: let _central, peripheral: _, advertismentData: _, RSSI: _):
			return central == _central
		case .didConnect(central: let _central, peripheral: _, error: _):
			return central == _central
		case .didDisconnect(central: let _central, peripheral: _, error: _):
			return central == _central
		}
	}

	func filter(peripheral: CBPeripheral) -> Bool {
		switch self {
		case .didUpdateState(central: _),
		     .willRestoreState(central: _, dict: _):
			return false
		case .didDiscover(central: _, peripheral: let _peripheral, advertismentData: _, RSSI: _):
			return peripheral == _peripheral
		case .didConnect(central: _, peripheral: let _peripheral, error: _):
			return peripheral == _peripheral
		case .didDisconnect(central: _, peripheral: let _peripheral, error: _):
			return peripheral == _peripheral
		}
	}

	func filter(peripheral identifier: UUID) -> Bool {
		switch self {
		case .didUpdateState(central: _),
		     .willRestoreState(central: _, dict: _):
			return false
		case .didDiscover(central: _, peripheral: let _peripheral, advertismentData: _, RSSI: _):
			return identifier.uuidString == _peripheral.identifier.uuidString
		case .didConnect(central: _, peripheral: let _peripheral, error: _):
			return identifier.uuidString == _peripheral.identifier.uuidString
		case .didDisconnect(central: _, peripheral: let _peripheral, error: _):
			return identifier.uuidString == _peripheral.identifier.uuidString
		}
	}

	func isDidUpdateStateEvent() -> Bool {
		switch self {
		case .didUpdateState(central: _):
			return true
		default:
			return false
		}
	}

	func isWillRestoreStateEvent() -> Bool {
		switch self {
		case .willRestoreState(central: _, dict: _):
			return true
		default:
			return false
		}
	}

	func isDidDiscoverEvent() -> Bool {
		switch self {
		case .didDiscover(central: _, peripheral: _, advertismentData: _, RSSI: _):
			return true
		default:
			return false
		}
	}

	func isDidConnectEvent() -> Bool {
		switch self {
		case .didConnect(central: _, peripheral: _, error: _):
			return true
		default:
			return false
		}
	}

	func isDidDisconnectEvent() -> Bool {
		switch self {
		case .didDisconnect(central: _, peripheral: _, error: _):
			return true
		default:
			return false
		}
	}
}
