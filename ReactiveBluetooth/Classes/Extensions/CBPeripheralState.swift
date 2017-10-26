//
//  File.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 25/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift

public extension CBPeripheralState {
	var description: String {
		switch self {
		case .connected: return "connected"
		case .connecting: return "connecting"
		case .disconnected: return "disconnected"
		case .disconnecting: return "disconnecting"
		}
	}
}

public extension PropertyProtocol where Value == CBPeripheralState {
	var isConnected: Property<Bool> {
		return self
			.map { $0.rawValue == CBPeripheralState.connected.rawValue }
	}

	var isConnecting: Property<Bool> {
		return self
			.map { $0.rawValue == CBPeripheralState.connecting.rawValue }
	}

	var isDisconnected: Property<Bool> {
		return self
			.map { $0.rawValue == CBPeripheralState.disconnected.rawValue }
	}

	var isDisconnecting: Property<Bool> {
		return self
			.map { $0.rawValue == CBPeripheralState.disconnecting.rawValue }
	}
}
