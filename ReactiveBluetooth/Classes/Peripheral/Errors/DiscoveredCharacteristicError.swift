//
//  DiscoveredCharacteristicError.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation

public struct DiscoveredCharacteristicError: Error {
	public let peripheral: CBPeripheral
	public let service: CBService
	public let error: NSError
}
