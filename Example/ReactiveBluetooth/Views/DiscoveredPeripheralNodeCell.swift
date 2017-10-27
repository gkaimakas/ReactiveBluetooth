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
import UIKit

class DiscoveredPeripheralNodeCell: ASCellNode {

	let card: DiscoveredPeripheralCard

	init(progress: Float) {
		card = DiscoveredPeripheralCard(progress: progress)
		super.init()

		self.card.cornerRadius = 20
		self.card.clipsToBounds = true
		self.backgroundColor = UIColor.flatWhite
		self.automaticallyManagesSubnodes = true
	}

	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

		let container = ASStackLayoutSpec
			.vertical()
			.withInset(UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 24))
			.withChildren([card])

		return container
	}
}
