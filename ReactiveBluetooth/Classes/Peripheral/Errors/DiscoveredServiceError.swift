//
//  DiscoveredServiceError.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation

public struct DiscoveredServiceError: Error {
	public let peripheral: CBPeripheral
	public let error: NSError
}
