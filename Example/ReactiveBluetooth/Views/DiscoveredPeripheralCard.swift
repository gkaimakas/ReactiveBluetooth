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
import ReplayKit
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

	init(progress: Float) {

		rssiProgress = ASProgressNode(progress: progress)
		
		super.init()

		self.addSubnode(connectionStateImage)
		self.addSubnode(nameLabel)
		self.addSubnode(rssiProgress)
		self.addSubnode(identifierTitleLabel)
		self.addSubnode(identifierLabel)
		self.addSubnode(actionButton)

		connectionStateImage.image = UIImage.image(with: UIColor.flatOrange, size: CGSize(width: 120, height: 120))

		nameLabel.attributedText = NSAttributedString(string: "Peripheral Name", attributes: [
			NSAttributedStringKey.foregroundColor : UIColor.darkGray,
			NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20)
			])

		identifierTitleLabel.attributedText = NSAttributedString(string: "Identifier", attributes: [
			NSAttributedStringKey.foregroundColor : UIColor.lightGray,
			NSAttributedStringKey.font: UIFont.systemFont(ofSize: 10)
			])

		identifierLabel.attributedText = NSAttributedString(string: "f3abbdde-bb0b-11e7-abc4-cec278b6b50a", attributes: [
			NSAttributedStringKey.foregroundColor : UIColor.darkGray,
			NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)
			])

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
					.withInset(UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
				,
				actionButton
					.withHeight(ASDimension(unit: ASDimensionUnit.points, value: 40))
				])

		return layout
	}
	
}
