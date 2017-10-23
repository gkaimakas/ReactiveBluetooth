//
//  PeripheralDisconnection.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation

public struct PeripheralDisconnection {
	public let central: CBCentralManager
	public let peripheral: CBPeripheral
}

extension PeripheralDisconnection: CentralManagerProvider {}

extension PeripheralDisconnection: PeripheralProvider {}

extension PeripheralDisconnection: PeripheralDisconnectionProvider {}
