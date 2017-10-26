//
//  DidUpdateValueForDescriptorEvent.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 26/10/2017.
//

import CoreBluetooth
import Foundation

class DidUpdateValueForDescriptorEvent: PeripheralEvent {
	let descriptor: CBDescriptor

	init?(event: PeripheralDelegateEvent) {
		switch event {
		case let .didUpdateValueForDescriptor(peripheral: peripheral, descriptor: descriptor, error: error):
			self.descriptor = descriptor
			super.init(peripheral: peripheral, error: error)
		default:
			return nil
		}
	}
}
