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
import UIKit

class ASProgressNode: ASDisplayNode {
	private var progressView: UIProgressView!
	private let progressNode: ASDisplayNode
	public var progress: Float {
		get {
			return progressView.progress
		}

		set {
			progressView?.progress = newValue
		}
	}

	override init() {
		weak var _self: ASProgressNode!
		progressNode = ASDisplayNode(viewBlock: { () -> UIView in
			_self.progressView = UIProgressView(progressViewStyle: .default)
			_self.progressView.progressTintColor = UIColor.flatPlum
			_self.progressView.trackTintColor = UIColor.flatWhite
			_self.progressView.progress = 0
			return _self.progressView
		})
		super.init()
		_self = self
		self.addSubnode(progressNode)
	}

	override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
		return ASStackLayoutSpec
			.horizontal()
			.withChildren([
				progressNode
					.withFlexGrow(1)
				])

	}
}
