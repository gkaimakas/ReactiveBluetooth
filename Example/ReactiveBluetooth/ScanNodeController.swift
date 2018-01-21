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

class ScanNodeController: ASViewController<ASTableNode> {
	let centralManager = CentralManager()
	var disposable = CompositeDisposable()
	var discoveredPeripherals: Array<AdvertisedPeripheralViewModel>

	init() {
		discoveredPeripherals = Array()

		super.init(node: ASTableNode())
		self.navigationItem.title = "Reactive Bluetooth"

		reactive.didDiscoverPeripheral <~ centralManager
			.state
			.producer
			.filter { $0 == .poweredOn }
			.flatMap(.latest) { _ -> SignalProducer<DiscoveredPeripheral, NoError> in
				return self.centralManager
					.scanForPeripherals(withServices: nil,
					                    options: [.allowDuplicates(true)])

			}
			.map { AdvertisedPeripheralViewModel(peripheral: $0) }
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
		node.allowsSelection = true
		node.backgroundColor = UIColor.flatWhite
		node.view.separatorStyle = .none
		node.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 4, right: 0)
	}

	func insertRows(in section: Int, count: Int) {
		let originalCount = discoveredPeripherals.count
		let startIndex = originalCount - count
		let endIndex =  discoveredPeripherals.count
		let indexRange = startIndex ..< endIndex
		let indexPaths = indexRange.map { IndexPath(row: $0, section: section) }
		node.insertRows(at: indexPaths, with: .fade)
	}
}

extension ScanNodeController: ASTableDataSource, ASTableDelegate {

	func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
		return discoveredPeripherals.count
	}

	func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
		let peripheral = discoveredPeripherals[indexPath.row]

		let node = AdvertisedPeripheralNode(viewModel: peripheral)
		node.cornerRadius = 12

		let wrapper = WrapperCellNode<AdvertisedPeripheralNode>(wrapped: node, inset: UIEdgeInsets(top: 4,
		                                                                                           left: 16,
		                                                                                           bottom: 12,
		                                                                                           right: 16))
		return wrapper
	}
}

extension Reactive where Base == ScanNodeController {

	var didDiscoverPeripheral: BindingTarget<AdvertisedPeripheralViewModel> {
		return makeBindingTarget { (base, peripheral) in


			if base.discoveredPeripherals.contains(peripheral) == false {
				base.discoveredPeripherals.append(peripheral)
				base.insertRows(in: 0, count: 1)
			}
		}
	}

	func updateRows(in section: Int) -> BindingTarget<[Any]> {
		return makeBindingTarget { $0.insertRows(in: section, count: $1.count) }
	}
}
