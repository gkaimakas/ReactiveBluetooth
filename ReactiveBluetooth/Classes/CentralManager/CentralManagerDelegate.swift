//
//  CentralManagerDelegate.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 23/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

public protocol CentralManagerDelegate {
	var didUpdateState: Signal<UpdatedManagerState, NoError> { get }
	var didDiscoverPeripheral: Signal<DiscoveredPeripheral, NoError> { get }
	var didConnectToPeripheral: Signal<Result<PeripheralConnection, PeripheralConnectionError>, NoError> { get }
	var didDisconnectFromPeripheral: Signal<Result<PeripheralDisconnection, PeripheralDisconnectionError>, NoError> { get }
	var didStopScan: Signal<CBCentralManager, NoError> { get }

	func scanForPeripherals(central: CBCentralManager,
	                        services: [CBUUID]?,
	                        options: [String: Any]?) -> SignalProducer<DiscoveredPeripheral, NoError>

	func stopScan(central: CBCentralManager) -> SignalProducer<CBCentralManager, NoError>
}
