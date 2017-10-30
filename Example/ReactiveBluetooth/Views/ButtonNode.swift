//
//  ButtonNode.swift
//  ReactiveBluetooth_Example
//
//  Created by George Kaimakas on 30/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import AsyncDisplayKit
import ASDKFluentExtensions
import ChameleonFramework
import Foundation
import ReactiveCocoa
import ReactiveSwift
import UIKit

class ButtonNode: ASDisplayNode {
	fileprivate var button: UIButton
	private let node: ASDisplayNode

	init(type: UIButtonType = UIButtonType.system) {
		self.button = UIButton(type: type)

		weak var _self: ButtonNode!

		node = ASDisplayNode(viewBlock: { () -> UIView in
			return _self.button
		})

		super.init()
		_self = self

		self.addSubnode(node)
	}

	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		return ASStackLayoutSpec
			.horizontal()
			.withChildren([
				node
					.withFlexGrow(1)
				])

	}
}

extension Reactive where Base: ButtonNode {
	func setAction(_ action: CocoaAction<UIButton>?) {
		base.button.reactive.pressed = action
	}

	func attributedText(for state: UIControlState = .normal) -> BindingTarget<NSAttributedString> {
		return makeBindingTarget { base, text in
			base.button.setAttributedTitle(text, for: state)
		}
	}

	var backgroundColor: BindingTarget<UIColor> {
		return makeBindingTarget { $0.button.backgroundColor = $1 }
	}
}
