//
//  ServiceProviderError.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation

public protocol ServiceProviderError: ServiceProvider, Error {
	var error: NSError { get }
}
