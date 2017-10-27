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
	var discoverProducer: SignalProducer<DiscoveredPeripheral, NoError>!
	var disposable = CompositeDisposable()
	let syncCache = SyncCollection<DiscoveredPeripheral>()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

		discoverProducer = centralManager
			.state
			.producer
			.filter { $0 == CBManagerState.poweredOn }
			.flatMap(.latest) { _ in return self.centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]) }


//		syncCache.reactive.sync <~ discoverProducer

		disposable += discoverProducer.start()

		syncCache
			.events
			.observeValues { event in
				switch event {
				case let .insert(element: element, at: index):
					print("Insert: \(element.peripheral.identifier.value)")
				default:
					break
				}
		}

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

