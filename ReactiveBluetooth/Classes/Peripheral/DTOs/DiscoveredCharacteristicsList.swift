//
//  DiscoveredCharacteristics.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

public struct DiscoveredCharacteristicsList {
	public let peripheral: CBPeripheral
	public let service: CBService
	public let characteristics: [DiscoveredCharacteristic]
	public let delegate: PeripheralDelegate

	public init(peripheral: CBPeripheral,
	            service: CBService,
	            characteristics: [CBCharacteristic],
	            delegate: PeripheralDelegate) {

		self.peripheral = peripheral
		self.service = service
		self.characteristics = characteristics
			.map { DiscoveredCharacteristic(peripheral: peripheral,
			                                service: service,
			                                characteristic: $0,
			                                delegate: delegate)
		}
		self.delegate = delegate
	}
}

extension DiscoveredCharacteristicsList: PeripheralProvider {}

extension DiscoveredCharacteristicsList: ServiceProvider {}
