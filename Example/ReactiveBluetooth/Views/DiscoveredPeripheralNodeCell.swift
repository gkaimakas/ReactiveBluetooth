//
//  DiscoveredPeripheralNodeCell.swift
//  ReactiveBluetooth_Example
//
//  Created by George Kaimakas on 27/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import AsyncDisplayKit
import ASDKFluentExtensions
import ChameleonFramework
import Foundation
import ReactiveBluetooth
import UIKit

class DiscoveredPeripheralNodeCell: ASCellNode {

	let card: DiscoveredPeripheralCard

	init(discoveredPeripheral: DiscoveredPeripheral) {
		card = DiscoveredPeripheralCard(discoveredPeripheral: discoveredPeripheral)
		super.init()

		self.addSubnode(card)

		self.card.cornerRadius = 12
		self.card.clipsToBounds = true
		self.card.shadowColor = UIColor.red.cgColor
		self.card.shadowRadius = 10
		self.card.shadowOffset = CGSize(width: 20, height: 20)
		self.card.shadowOpacity = 1
		self.backgroundColor = UIColor.flatWhite
		self.automaticallyManagesSubnodes = true
	}

	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

		let container = ASStackLayoutSpec
			.vertical()
			.withInset(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
			.withChildren([card])

		return container
	}
}
