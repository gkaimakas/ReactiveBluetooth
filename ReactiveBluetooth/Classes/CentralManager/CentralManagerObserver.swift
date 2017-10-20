//
//  CentralManagerObserver.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

public class CentralManager: NSObject {
	public let peripheralDelegate: PeripheralDelegate

	public let didUpdateState: Signal<UpdatedManagerState, NoError>
	public let didUpdateStateObserver: Signal<UpdatedManagerState, NoError>.Observer

	public let didDiscoverPeripheral: Signal<DiscoveredPeripheral, NoError>
	public let didDiscoverPeripheralObserver: Signal<DiscoveredPeripheral, NoError>.Observer

	public let didConnectToPeripheral: Signal<Result<PeripheralConnection, PeripheralConnectionError>, NoError>
	public let didConnectToPeripheralObserver: Signal<Result<PeripheralConnection, PeripheralConnectionError>, NoError>.Observer

	public let didDisconnectFromPeripheral: Signal<Result<PeripheralDisconnection, PeripheralDisconnectionError>, NoError>
	public let didDisconnectFromPeripheralObserver: Signal<Result<PeripheralDisconnection, PeripheralDisconnectionError>, NoError>.Observer
	

	public init(peripheralDelegate: PeripheralDelegate) {
		self.peripheralDelegate = peripheralDelegate

		(didUpdateState, didUpdateStateObserver) = Signal.pipe()
		(didDiscoverPeripheral, didDiscoverPeripheralObserver) = Signal.pipe()
		(didConnectToPeripheral, didConnectToPeripheralObserver) = Signal.pipe()
		(didDisconnectFromPeripheral, didDisconnectFromPeripheralObserver) = Signal.pipe()
	}

}

extension CentralManager: CBCentralManagerDelegate {
	public func centralManagerDidUpdateState(_ central: CBCentralManager) {
		let state = UpdatedManagerState(central: central,
		                                state: central.state)
		didUpdateStateObserver.send(value: state)

	}

	public func centralManager(_ central: CBCentralManager,
	                           didDiscover peripheral: CBPeripheral,
	                           advertisementData: [String : Any],
	                           rssi RSSI: NSNumber) {

		let discoveredPeripheral = DiscoveredPeripheral(central: central,
		                                                peripheral: peripheral,
		                                                advertismentData: advertisementData,
		                                                RSSI: RSSI)

		didDiscoverPeripheralObserver.send(value: discoveredPeripheral)

	}

	public func centralManager(_ central: CBCentralManager,
	                           didConnect peripheral: CBPeripheral) {

		let connection = PeripheralConnection(central: central,
		                                      peripheral: peripheral)
		let result = Result<PeripheralConnection, PeripheralConnectionError>(value: connection)
		didConnectToPeripheralObserver.send(value: result)

	}

	public func centralManager(_ central: CBCentralManager,
	                           didFailToConnect peripheral: CBPeripheral,
	                           error: Error?) {

		if let error = error as NSError? {
			let result = Result<PeripheralConnection, PeripheralConnectionError>(error: PeripheralConnectionError(central: central,
			                                                                                                      peripheral: peripheral,
			                                                                                                      error: error))
			didConnectToPeripheralObserver.send(value: result)
		}

	}

	public func centralManager(_ central: CBCentralManager,
	                           didDisconnectPeripheral peripheral: CBPeripheral,
	                           error: Error?) {

		if let error = error as NSError? {
			let result = Result<PeripheralDisconnection, PeripheralDisconnectionError>(error: PeripheralDisconnectionError(central: central,
			                                                                                                               peripheral: peripheral,
			                                                                                                               error: error))

			didDisconnectFromPeripheralObserver.send(value: result)
			return
		}

		let result = Result<PeripheralDisconnection, PeripheralDisconnectionError>(value: PeripheralDisconnection(central: central,
		                                                                                                               peripheral: peripheral))
		didDisconnectFromPeripheralObserver.send(value: result)



	}
}
