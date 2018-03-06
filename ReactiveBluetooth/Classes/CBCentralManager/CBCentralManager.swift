//
//  CBCentralManager.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 06/03/2018.
//

import CoreBluetooth

extension CBCentralManager {
    convenience public init(delegate: CBCentralManagerDelegate?, queue: DispatchQueue?, options: Set<CBCentralManager.InitializationOption>? = nil) {

        self.init(delegate: delegate,
                  queue: queue,
                  options: options?.merge())
    }
}
