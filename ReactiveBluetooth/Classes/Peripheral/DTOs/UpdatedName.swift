//
//  UpdatedName.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 19/10/2017.
//

import CoreBluetooth
import Foundation

public struct UpdatedName {
	public let peripheral: CBPeripheral
	public let name: String?

	public init(peripheral: CBPeripheral) {
		self.peripheral = peripheral
		self.name = peripheral.name
	}
}
