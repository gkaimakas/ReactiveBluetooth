//
//  IncludedService.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 24/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

public class IncludedService: Service {
	public let parent: Service

	internal init(peripheral: Peripheral,
	                       parent: Service,
	                       service: CBService,
	                       delegate: PeripheralObserver) {
		self.parent = parent

		super.init(peripheral: peripheral,
		           service: service,
		           delegate: delegate)
	}
}
