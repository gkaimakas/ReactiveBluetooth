//
//  ServiceProvider.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 20/10/2017.
//

import CoreBluetooth
import Foundation

public protocol ServiceProvider {
	var service: CBService { get }
}
