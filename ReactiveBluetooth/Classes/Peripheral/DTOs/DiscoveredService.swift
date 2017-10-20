//
//  DiscoveredService.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 19/10/2017.
//

import CoreBluetooth
import Foundation

public struct DiscoveredService {
	public let peripheral: CBPeripheral
	public let service: CBService
}

extension DiscoveredService: PeripheralProvider {}

extension DiscoveredService: ServiceProvider {}
