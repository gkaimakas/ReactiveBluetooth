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
	var main = MutableProperty<Service?>(nil)
	var battery = MutableProperty<Service?>(nil)

	var disposable = CompositeDisposable()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

		let producer = centralManager
			.state
			.producer
			.promoteError(NSError.self)
			.filter { $0 == CBManagerState.poweredOn }
			.flatMap(.latest) { _ in return self.centralManager.scanForPeripherals(withServices: nil) }
			.take(first: 1)

		disposable += peripheral <~ producer
			.flatMapError { _ in return SignalProducer.empty }

		disposable += main <~ peripheral
			.producer
			.skipNil()
			.flatMap(.latest) { $0.services.producer.map { Array($0) }.flatten()}
			.filter(service: "5AF91801-0140-4F26-B16A-1CE6140D552D")

		disposable += battery <~ peripheral
			.producer
			.skipNil()
			.flatMap(.latest) { $0.services.producer.map { Array($0) }.flatten()}
			.filter(service: "180F")


		disposable += producer
			.flatMap(.latest) { _peripheral -> SignalProducer<Peripheral, NSError> in _peripheral.nonBlocking.connect() }
			.flatMap(.merge) { _peripheral -> SignalProducer<Characteristic, NSError> in
				return _peripheral
					.nonBlocking
					.discoverServices()
					.on(value: { print("Service", $0.uuid.value.uuidString) })
					.flatMap(.merge) { $0.nonBlocking.discoverCharacteristics() }
					.on(value: { print("Characterstic", $0.uuid.value.uuidString, $0.service.uuid.value.uuidString) })
			}
			.then(centralManager.stopScan())
			.start()

//		disposable += peripheral
//			.producer
//			.skipNil()
//			.flatMap(.latest) { $0.state.producer }
//			.startWithValues { state in
//				print(state.description)
//		}

//		disposable += main
//			.producer
//			.skipNil()
//			.map { $0.uuid.value.uuidString }
//			.startWithValues { print("Main Service: \($0)") }

		let discoverProducer = peripheral
			.producer
			.skipNil()
			.flatMap(.latest) { $0.state.isConnected.producer
				.filter { $0 }
				.promoteError(NSError.self)
				.flatMap(.latest) { _ in self
					.peripheral
					.producer
					.skipNil()
					.promoteError(NSError.self)
					.flatMap(.latest) { peripheral -> SignalProducer<Service, NSError> in return peripheral.nonBlocking.discoverServices() }
					.flatMap(.latest) { service -> SignalProducer<Characteristic, NSError> in return service.nonBlocking.discoverCharacteristics() }
				}
			}

		discoverProducer
			.startWithResult { (result) in
				switch result {
				case .success(let characteristic):
					print(characteristic.uuid.value.uuidString)
				case .failure(let error):
					print(error.localizedDescription)
				}
		}

//			.on(value: {val in  print("Service: ") })
//			.flatMap(.merge) { service -> SignalProducer<Characteristic, NSError> in return service.discoverCharacteristics() }


//		disposable += main
//			.producer
//			.skipNil()
//
//			.flatMap(.latest) { $0.nonBlocking.discoverCharacteristics() }
//			.map { characteristic -> String in return characteristic.uuid.value.uuidString }
//			.on(value: { print("Main Characteristic", $0) })
//			.start()

//		disposable += battery
//			.producer
//			.skipNil()
//			.flatMap(.latest) { $0.nonBlocking.discoverCharacteristics([CBUUID(string: "5AF91803-0140-4F26-B16A-1CE6140D552D")]) }
//			.map { characteristic -> String in return characteristic.uuid.value.uuidString }
//			.on(value: { print("Battery Characteristic", $0) })
//			.start()


//		disposable += battery
//			.producer
//			.skipNil()
//			.map { $0.uuid.value.uuidString }
//			.startWithValues { print("Battery Service: \($0)") }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

