//
//  DiscoveredCharacteristic.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 19/10/2017.
//

import CoreBluetooth
import Foundation

public struct DiscoveredCharacteristic {
	public let peripheral: CBPeripheral
	public let service: CBService
	public let characteristic: CBCharacteristic
}
