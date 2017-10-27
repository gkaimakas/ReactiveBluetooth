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
	private var progressNode: ASDisplayNode
	init(progress: Float) {
		progressNode = ASDisplayNode(viewBlock: { () -> UIView in
			let progressView = UIProgressView(progressViewStyle: .default)
			progressView.progressTintColor = UIColor.flatPlum
			progressView.trackTintColor = UIColor.flatWhite
			progressView.progress = progress
			return progressView
		})
		super.init()
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
