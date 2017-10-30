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

class AdvertisedPeripheralNode: ASDisplayNode {
	let connectionStateImage: ASImageNode = {
		let node = ASImageNode()
		node.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(0, nil)
		node.contentMode = UIViewContentMode.scaleAspectFit
		return node
	}()

	let nameLabelNode = ASTextNode()

	let rssiValueNode = ASTextNode()
	let rssiProgressNode = ProgressNode()

	let identifierTitleLabelNode = ASTextNode()
	let identifierLabelNode: ASTextNode = {
		let node = ASTextNode()
		node.truncationMode = NSLineBreakMode.byWordWrapping
		node.maximumNumberOfLines = 0
		return node
	}()

	let actionButtonNode = ButtonNode()

	init(viewModel: AdvertisedPeripheralViewModel) {
		super.init()

		self.addSubnode(connectionStateImage)
		self.addSubnode(nameLabelNode)
		self.addSubnode(rssiValueNode)
		self.addSubnode(rssiProgressNode)
		self.addSubnode(identifierTitleLabelNode)
		self.addSubnode(identifierLabelNode)
		self.addSubnode(actionButtonNode)

		connectionStateImage.image = UIImage.image(with: UIColor.flatOrange, size: CGSize(width: 120, height: 120))

		rssiValueNode.reactive.attributedText <~ viewModel
			.RSSI
			.producer
			.map { $0.floatValue }
			.map { Int($0) }
			.map { "RSSI: \($0)dB" }
			.attributedString(color: .darkGray, size: 10)

		rssiProgressNode.reactive.progress <~ viewModel
			.RSSI
			.producer
			.map { $0.floatValue }
			.map { abs($0) }
			.map { $0/200 }
			.take(during: reactive.lifetime)


		let connectionStateColorProducer: SignalProducer<UIColor, NoError> = viewModel
			.state
			.producer
			.map { state -> UIColor in
				switch state {
				case .connected: return UIColor.flatGreenDark
				case .connecting: return UIColor.flatYellowDark
				case .disconnecting: return UIColor.flatYellowDark
				case .disconnected: return UIColor.flatSkyBlue
				}
		}
		connectionStateImage.reactive.image <~ connectionStateColorProducer
			.map { color -> UIImage in
				return UIImage.image(with: color, size: CGSize(width: 120, height: 120))
			}
			.take(during: reactive.lifetime)

		nameLabelNode.reactive.attributedText <~ viewModel
			.peripheral
			.peripheral
			.name
			.producer
			.map { $0 ?? "[Name Not Available]" }
			.boldAttributedString(color: .darkGray, size: 20)
			.take(during: reactive.lifetime)

		identifierTitleLabelNode.reactive.attributedText <~ SignalProducer<String, NoError>(value: "Identifier")
			.attributedString(color: .lightGray, size: 10)
			.take(during: reactive.lifetime)

		identifierLabelNode.reactive.attributedText <~ viewModel
			.peripheral
			.peripheral
			.identifier
			.producer
			.map { $0.uuidString }
			.attributedString(color: .darkGray, size: 16)
			.take(during: reactive.lifetime)

		actionButtonNode.reactive.attributedText() <~ viewModel
			.state
			.producer
			.flatMap(.latest) { state -> SignalProducer<NSAttributedString, NoError> in
				var result: String
				switch state {
				case .connected:
					result = "Disconnect"
				case .connecting:
					result = "Connecting..."
				case .disconnected:
					result = "Connect"
				case .disconnecting:
					result = "Disconnectiong..."
				}

				return SignalProducer<String, NoError>(value: result)
					.boldAttributedString(color: .white, size: 16)
			}
			.take(during: reactive.lifetime)

		actionButtonNode.reactive.setAction(CocoaAction<UIButton>(viewModel.toggleConnection))
		actionButtonNode.reactive.backgroundColor <~ connectionStateColorProducer
		actionButtonNode.isUserInteractionEnabled = true

		self.backgroundColor = UIColor.white
		self.clipsToBounds = true
		self.automaticallyManagesSubnodes = true
	}

	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		let nameLayout = ASStackLayoutSpec
			.vertical()
			.withSpacing(4)
			.withFlexShrink(1)
			.withChildren([
				nameLabelNode,
				rssiProgressNode
					.withFlexGrow(1),
				rssiValueNode
				])

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
							.withAlignItems(ASStackLayoutAlignItems.center)
							.withChildren([
								connectionStateImage
									.withPreferredSize(CGSize(width: 40, height: 40))
									.withFlexGrow(0),
								nameLayout,
								]),
						ASStackLayoutSpec
							.vertical()
							.withSpacing(2)
							.withChildren([
								identifierTitleLabelNode,
								identifierLabelNode
								])
						])
					.withSpacing(8)
					.withInset(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
				,
				actionButtonNode
					.withHeight(ASDimension(unit: ASDimensionUnit.points, value: 40))
				])

		return layout
	}
	
}
