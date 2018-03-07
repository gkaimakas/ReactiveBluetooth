//
//  UITableViewCell.swift
//  ReactiveBluetooth_Example
//
//  Created by George Kaimakas on 06/03/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell {
    public static var nib: UINib {
        return UINib(nibName: identifier, bundle: Bundle(for: self))
    }
}
