//
//  ReadRSSIError.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation

public struct ReadRSSIError: Error {
	public let peripheral: CBPeripheral
	public let error: NSError
}

extension ReadRSSIError: PeripheralProviderError {}
