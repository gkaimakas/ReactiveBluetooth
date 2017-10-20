//
//  PeripheralDisconnectionError.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation

public struct PeripheralDisconnectionError: Error {
	public let central: CBCentralManager
	public let peripheral: CBPeripheral
	public let error: NSError
}

extension PeripheralDisconnectionError: CentralManagerProvider {}

extension PeripheralDisconnectionError: PeripheralProvider {}

extension PeripheralDisconnectionError: ErrorProvider {}
