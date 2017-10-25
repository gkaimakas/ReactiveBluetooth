//
//  ViewController.swift
//  ReactiveBluetooth
//
//  Created by gkaimakas on 10/20/2017.
//  Copyright (c) 2017 gkaimakas. All rights reserved.
//

import CoreBluetooth
import ReactiveBluetooth
import ReactiveSwift
import Result
import UIKit

class ViewController: UIViewController {
	let centralManager = CentralManager()

	var peripheral: MutableProperty<Peripheral?> = MutableProperty(nil)


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

		let producer = centralManager
			.state
			.producer
			.promoteError(NSError.self)
			.filter { $0 == CBManagerState.poweredOn }
			.flatMap(.latest) { _ in return self.centralManager.scanForPeripherals(withServices: [CBUUID(string: "5AF91801-0140-4F26-B16A-1CE6140D552D")]) }
			.take(first: 1)

		peripheral <~ producer
			.flatMapError { _ in return SignalProducer.empty }

		producer
			.flatMap(.latest) { $0.connect() }
			.flatMap(.latest) { _peripheral -> SignalProducer<Service, NSError> in
				return _peripheral.discoverServices()
			}
			.flatMap(.concat) { _service -> SignalProducer<Characteristic, NSError> in
				return _service.discoverCharacteristics()
			}
			.map { $0.uuid.uuidString }
			.then(centralManager.stopScan())
			.then(self.peripheral
				.producer
				.skipNil()
				.flatMap(.latest) { $0.disconnect() }
			)
			.start()

		peripheral
			.producer
			.skipNil()
			.flatMap(.latest) { $0.state.producer }
			.startWithValues { state in
				print(state.description)
		}

		peripheral
			.producer
			.skipNil()
			.flatMap(.latest) { $0.name.producer }
			.startWithValues { print($0) }

		centralManager
			.isScanning
			.producer
			.startWithValues { print("isScanning ---- \($0)") }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

