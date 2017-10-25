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

	var peripheral: Peripheral!


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
			.flatMap(.latest) { $0.connect() }
			.on(value: { self.peripheral = $0 })


		producer
			.flatMap(.latest) { _peripheral -> SignalProducer<Service, NSError> in
				return _peripheral.discoverServices()
			}
			.flatMap(.concat) { _service -> SignalProducer<Characteristic, NSError> in
				print("Service: \(_service.uuid.uuidString)")
				return _service.discoverCharacteristics()
			}
			.map { $0.uuid.uuidString }
			.on(value: { print($0) })
			.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

