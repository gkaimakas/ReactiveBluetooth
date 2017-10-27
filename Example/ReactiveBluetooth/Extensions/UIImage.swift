//
//  UIImage.swift
//  ReactiveBluetooth_Example
//
//  Created by George Kaimakas on 27/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {

	static func image(with color: UIColor, size: CGSize) -> UIImage {
		let rect = CGRect(origin: CGPoint(x: 0, y:0), size: size)
		UIGraphicsBeginImageContext(rect.size)
		let context = UIGraphicsGetCurrentContext()!

		context.setFillColor(color.cgColor)
		context.fill(rect)

		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return image!
	}
}
