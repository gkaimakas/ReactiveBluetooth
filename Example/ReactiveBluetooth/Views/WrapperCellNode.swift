//
//  CellNode.swift
//  ReactiveBluetooth_Example
//
//  Created by George Kaimakas on 28/10/2017.
//  Copyright © 2017 George Kaimakas. All rights reserved.
//

import AsyncDisplayKit
import ASDKFluentExtensions
import ChameleonFramework
import Foundation
import ReactiveCocoa
import ReactiveSwift
import Result
import UIKit

public class WrapperCellNode<Node: ASDisplayNode>: ASCellNode {

	let wrappedNode: Node
	let inset: UIEdgeInsets

	public init(wrapped: Node, inset: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)) {

		self.wrappedNode = wrapped
		self.inset = inset

		super.init()

		self.selectionStyle = .none
		self.automaticallyManagesSubnodes = true
	}

	override public func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

		let container = ASStackLayoutSpec
			.vertical()
			.withInset(inset)
			.withChildren([wrappedNode])

		return container
	}
}
