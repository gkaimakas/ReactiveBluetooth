//
//  ASProgressNode.swift
//  ReactiveBluetooth_Example
//
//  Created by George Kaimakas on 27/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import AsyncDisplayKit
import ASDKFluentExtensions
import ChameleonFramework
import Foundation
import ReactiveCocoa
import ReactiveSwift
import UIKit

class ProgressNode: ASDisplayNode {
	private var progressView: UIProgressView
	private let node: ASDisplayNode
	public var progress: Float {
		get {
			return progressView.progress
		}

		set {
			progressView.setProgress(newValue, animated: true)
		}
	}

	override init() {
		self.progressView = UIProgressView(progressViewStyle: .default)
		self.progressView.progressTintColor = UIColor.flatPlum
		self.progressView.trackTintColor = UIColor.flatWhite
		self.progressView.progress = 0

		weak var _self: ProgressNode!

		node = ASDisplayNode(viewBlock: { () -> UIView in
			return _self.progressView
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

extension Reactive where Base: ProgressNode {
	var progress: BindingTarget<Float> {
		return makeBindingTarget { $0.progress = $1 }
	}
}
