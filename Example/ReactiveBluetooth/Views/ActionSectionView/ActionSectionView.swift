//
//  ActionSectionView.swift
//  ReactiveBluetooth_Example
//
//  Created by George Kaimakas on 07/03/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift
import UIKit

public final class ActionSectionView: UIView {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initializeView()
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionButton: ActionButton!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeView()
    }

    func initializeView() {
        let view: UIView? = Bundle(for: ActionSectionView.self)
            .loadNibNamed(String(describing: ActionSectionView.self), owner: self, options: nil)?.last as? UIView

        if let view = view {
            view.frame = self.bounds
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            addSubview(view)
        }
    }
}
