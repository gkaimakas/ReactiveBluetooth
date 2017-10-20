//
//  UpdatedNotificationStateError.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation

public struct UpdatedNotificationStateError: Error {
	public let peripheral: CBPeripheral
	public let characteristic: CBCharacteristic
	public let error: NSError
}
