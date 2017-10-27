//
//  DiscoveredPeripheralCard.swift
//  ReactiveBluetooth_Example
//
//  Created by George Kaimakas on 27/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import AsyncDisplayKit
import ASDKFluentExtensions
import Foundation
import ReactiveCocoa
import ReactiveBluetooth
import ReactiveSwift
import Result

class DiscoveredPeripheralCard: ASDisplayNode {
	let connectionStateImage: ASImageNode = {
		let node = ASImageNode()
		node.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(0, nil)
		node.contentMode = UIViewContentMode.scaleAspectFit
		return node
	}()

	let nameLabel = ASTextNode()

	let rssiProgress: ASProgressNode

	let identifierTitleLabel = ASTextNode()
	let identifierLabel: ASTextNode = {
		let node = ASTextNode()
		node.truncationMode = NSLineBreakMode.byWordWrapping
		node.maximumNumberOfLines = 0
		return node
	}()

	let actionButton = ASButtonNode()

	init(discoveredPeripheral: DiscoveredPeripheral) {

		rssiProgress = ASProgressNode()
		
		super.init()

		self.addSubnode(connectionStateImage)
		self.addSubnode(nameLabel)
		self.addSubnode(rssiProgress)
		self.addSubnode(identifierTitleLabel)
		self.addSubnode(identifierLabel)
		self.addSubnode(actionButton)

		connectionStateImage.image = UIImage.image(with: UIColor.flatOrange, size: CGSize(width: 120, height: 120))

		rssiProgress.reactive.progress <~ discoveredPeripheral
			.RSSI
			.producer
			.map { $0.floatValue }
			.map { -$0 }
			.map { $0/100 }

		connectionStateImage.reactive.image <~ discoveredPeripheral
			.peripheral
			.state
			.producer
			.map { state -> UIImage in
				switch state {
				case .connected: return UIImage.image(with: UIColor.flatGreen, size: CGSize(width: 120, height: 120))
				case .connecting: return UIImage.image(with: UIColor.flatBlue, size: CGSize(width: 120, height: 120))
				case .disconnecting: return UIImage.image(with: UIColor.flatYellow, size: CGSize(width: 120, height: 120))
				case .disconnected: return UIImage.image(with: UIColor.flatOrange, size: CGSize(width: 120, height: 120))
				}
			}

		nameLabel.reactive.attributedText <~ discoveredPeripheral
			.peripheral
			.name
			.producer
			.map { $0 ?? "Not Available" }
			.boldAttributedString(color: .darkGray, size: 20)

		identifierTitleLabel.reactive.attributedText <~ SignalProducer<String, NoError>(value: "Identifier")
			.attributedString(color: .lightGray, size: 10)

		identifierLabel.reactive.attributedText <~ discoveredPeripheral
			.peripheral
			.identifier
			.producer
			.map { $0.uuidString }
			.attributedString(color: .darkGray, size: 16)

		actionButton.setAttributedTitle(NSAttributedString(string: "Connect", attributes: [
			NSAttributedStringKey.foregroundColor : UIColor.white,
			NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16)
			]), for: .normal)

		actionButton.backgroundColor = UIColor.flatMint
		actionButton.isUserInteractionEnabled = true

		self.backgroundColor = UIColor.white
		self.automaticallyManagesSubnodes = true
	}

	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let layout = ASStackLayoutSpec
			.vertical()
			.withChildren([
				ASStackLayoutSpec
					.vertical()
					.withChildren([
						ASStackLayoutSpec
							.horizontal()
							.alignItems(.center)
							.withSpacing(8)
							.withChildren([
								connectionStateImage
									.withPreferredSize(CGSize(width: 40, height: 40))
									.withFlexGrow(0),
								ASStackLayoutSpec
									.vertical()
									.withSpacing(4)
									.withChildren([
										nameLabel,
										rssiProgress
										])
									.withInset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8))
									.withFlexGrow(1),
								]),
						ASStackLayoutSpec
							.vertical()
							.withSpacing(2)
							.withChildren([
								identifierTitleLabel,
								identifierLabel
								])
						])
					.withSpacing(8)
					.withInset(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
				,
				actionButton
					.withHeight(ASDimension(unit: ASDimensionUnit.points, value: 40))
				])

		return layout
	}
	
}
