//
//  ErrorProvider.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import Foundation

public protocol ErrorProvider: Error {
	var error: NSError { get }
}
