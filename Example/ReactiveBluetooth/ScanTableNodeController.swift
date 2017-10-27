//
//  ScanTableNodeController.swift
//  ReactiveBluetooth_Example
//
//  Created by George Kaimakas on 27/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import AsyncDisplayKit
import ASDKFluentExtensions
import ChameleonFramework
import CoreBluetooth
import Foundation
import ReactiveCocoa
import ReactiveBluetooth
import ReactiveSwift
import Result

class ScanTableNodeController: ASViewController<ASTableNode> {
	let centralManager = CentralManager()
	var disposable = CompositeDisposable()
	let syncCache = SyncArray<DiscoveredPeripheral>()

	init() {
		super.init(node: ASTableNode())
		self.navigationItem.title = "Reactive Bluetooth"

		syncCache.reactive.sync <~ centralManager
			.state
			.producer
			.filter { $0 == CBManagerState.poweredOn }
			.flatMap(.latest) { _ in return self.centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]) }


		node.reactive.reloadData() <~ syncCache
			.events
			.map { _ in return () }
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		node.autoresizingMask = [.flexibleHeight, .flexibleWidth]
		node.dataSource = self
		node.delegate = self
		node.isUserInteractionEnabled = true
		node.allowsSelection = false
		node.view.separatorStyle = .none
	}
}

extension ScanTableNodeController: ASTableDataSource, ASTableDelegate {
//	func numberOfSections(in tableNode: ASTableNode) -> Int {
//		return 1
//	}

	func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
		return syncCache.count
	}

	func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
		let peripheral = syncCache[indexPath.row]
		let nodeBlock: ASCellNodeBlock = {
			return DiscoveredPeripheralNodeCell(discoveredPeripheral: peripheral)
		}
		return nodeBlock
	}
}
