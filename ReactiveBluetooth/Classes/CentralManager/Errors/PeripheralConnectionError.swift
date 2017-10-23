//
//  PeripheralConnectionError.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation

public struct PeripheralConnectionError: Error {
	public let central: CBCentralManager
	public let peripheral: CBPeripheral
	public let error: NSError
}

extension PeripheralConnectionError: CentralManagerProvider {}

extension PeripheralConnectionError: PeripheralProvider {}

extension PeripheralConnectionError: ErrorProvider {}

extension PeripheralConnectionError: PeripheralConnectionErrorProvider {}
