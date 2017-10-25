//
//  File.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 25/10/2017.
//

import CoreBluetooth
import Foundation

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
