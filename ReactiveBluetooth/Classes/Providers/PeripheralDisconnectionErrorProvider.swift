//
//  PeripheralDisconnectionErrorProvider.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 23/10/2017.
//

import CoreBluetooth
import Foundation

public protocol PeripheralDisconnectionErrorProvider: CentralManagerProvider, PeripheralProvider, ErrorProvider {}
