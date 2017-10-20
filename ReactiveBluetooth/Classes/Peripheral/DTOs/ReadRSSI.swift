//
//  ReadRSSI.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation

public struct ReadRSSI {
	public let peripheral: CBPeripheral
	public let RSSI: NSNumber
}

extension ReadRSSI: PeripheralProvider {}
