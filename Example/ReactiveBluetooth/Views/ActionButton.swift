//
//  ActionButton.swift
//  ReactiveBluetooth_Example
//
//  Created by George Kaimakas on 06/03/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

public class ActionButton: UIButton {
    private let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))

    override public init(frame: CGRect) {
        super.init(frame: frame)

        configure()
        
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        configure()
    }

    private func configure() {
        addSubview(activityIndicator)
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.startAnimating()
        activityIndicator.color = tintColor

        bringSubview(toFront: activityIndicator)

        layer.borderColor = tintColor.cgColor
        layer.borderWidth = 0.5
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 32, bottom: 8, right: 32)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = self.frame.height/2
        activityIndicator.frame = CGRect(x: frame.width-28, y: (frame.height - 24)/2, width: 24, height: 24)
    }
}
