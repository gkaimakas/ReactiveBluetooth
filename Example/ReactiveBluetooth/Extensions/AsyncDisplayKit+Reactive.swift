//
//  ASTextNode+Reactive.swift
//  ReactiveBluetooth_Example
//
//  Created by George Kaimakas on 28/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import AsyncDisplayKit
import Foundation
import ReactiveCocoa
import ReactiveSwift

extension Reactive where Base: ASTextNode {
	var attributedText: BindingTarget<NSAttributedString> {
		return makeBindingTarget { $0.attributedText = $1 }
	}
}

extension Reactive where Base: ASImageNode {
	var image: BindingTarget<UIImage> {
		return makeBindingTarget { $0.image = $1 }
	}
}

extension Reactive where Base: ASTableNode {
	func reloadData() -> BindingTarget<Void> {
		return makeBindingTarget { (node, _) in node.reloadData() }
	}
}

extension Reactive where Base: ASButtonNode {
}
