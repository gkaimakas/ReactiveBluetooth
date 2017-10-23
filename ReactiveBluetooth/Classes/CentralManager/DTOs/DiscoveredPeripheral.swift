//
//  DiscoveredPeripheral.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation

public struct DiscoveredPeripheral {
	public let central: CBCentralManager
	public let peripheral: CBPeripheral
	public let advertismentData: [String: Any]
	public let RSSI: NSNumber
}

extension DiscoveredPeripheral: CentralManagerProvider {}

extension DiscoveredPeripheral: PeripheralProvider {}

extension DiscoveredPeripheral: RSSIProvider {}
