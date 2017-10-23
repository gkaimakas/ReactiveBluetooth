//
//  ManagerStateProvider.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 23/10/2017.
//

import CoreBluetooth
import Foundation

public protocol ManagerStateProvider {
	var state: CBManagerState { get }
}
