//
//  WrittenValueError.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation

public struct WrittenValueError: Error {
	public let peripheral: CBPeripheral
	public let characteristic: CBCharacteristic
	public let error: NSError
}

extension WrittenValueError: PeripheralProviderError {}

extension WrittenValueError: CharacteristicProviderError {}
