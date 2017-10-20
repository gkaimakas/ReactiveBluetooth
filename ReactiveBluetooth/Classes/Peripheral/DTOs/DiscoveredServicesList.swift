//
//  DiscoveredServicesList.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation

public struct DiscoveredServicesList {
	public let peripheral: CBPeripheral
	public let services: [DiscoveredService]
	public let delegate: PeripheralDelegate

	public init(peripheral: CBPeripheral,
	            services: [CBService],
	            delegate: PeripheralDelegate) {

		self.peripheral = peripheral
		self.services = services
			.map { DiscoveredService(peripheral: peripheral,
			                         service: $0,
			                         delegate: delegate)
		}
		self.delegate = delegate
	}
}

extension DiscoveredServicesList: PeripheralProvider {}
