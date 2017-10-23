//
//  UpdateManagerState.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation

public struct UpdatedManagerState {
	public let central: CBCentralManager
	public let state: CBManagerState
}

extension UpdatedManagerState: CentralManagerProvider {}

extension UpdatedManagerState: ManagerStateProvider {}
