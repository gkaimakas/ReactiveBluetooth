//
//  CBService+Associations.swift
//  ReactiveCoreBluetooth
//
//  Created by George Kaimakas on 04/03/2018.
//

import CoreBluetooth

extension CBService {
    internal class Associations {
        internal static var isPrimary = "com.gkaimakas.ReactiveCoreBluetooth.CBService.isPrimary"
        internal static var includedServices = "com.gkaimakas.ReactiveCoreBluetooth.CBService.includedServices"
        internal static var characteristics = "com.gkaimakas.ReactiveCoreBluetooth.CBService.characteristics"

    }
}
