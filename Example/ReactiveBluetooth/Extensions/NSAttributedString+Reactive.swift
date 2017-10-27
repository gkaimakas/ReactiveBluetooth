//
//  NSAttributedString+Reactive.swift
//  ReactiveBluetooth_Example
//
//  Created by George Kaimakas on 28/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import Result

extension SignalProducer where Value == String {
	func boldAttributedString(color: UIColor, size: CGFloat) -> SignalProducer<NSAttributedString, Error> {
		return  self.map{ value -> NSAttributedString in
			return NSAttributedString(string: value, attributes: [
				NSAttributedStringKey.foregroundColor : color,
				NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: size)
				])
		}
	}

	func attributedString(color: UIColor, size: CGFloat) -> SignalProducer<NSAttributedString, Error> {
		return  self.map{ value -> NSAttributedString in
			return NSAttributedString(string: value, attributes: [
				NSAttributedStringKey.foregroundColor : color,
				NSAttributedStringKey.font: UIFont.systemFont(ofSize: size)
				])
		}
	}
}
