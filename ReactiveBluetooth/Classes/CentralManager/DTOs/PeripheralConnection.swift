//
//  PeripheralConnection.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation

public struct PeripheralConnection {
	public let central: CBCentralManager
	public let peripheral: CBPeripheral
}

extension PeripheralConnection: CentralManagerProvider {}

extension PeripheralConnection: PeripheralProvider {}
