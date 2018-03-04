//
//  CBPeripheral+Associations.swift
//  FBSnapshotTestCase
//
//  Created by George Kaimakas on 02/03/2018.
//

import CoreBluetooth

extension CBPeripheral {
    internal class Associations {
        internal static var centralManager = "com.gkaimakas.ReactiveCoreBluetooth.CBPeripheral.centralManager"
        internal static var delegate = "com.gkaimakas.ReactiveCoreBluetooth.CBPeripheral.delegate"
        internal static var name = "com.gkaimakas.ReactiveCoreBluetooth.CBPeripheral.name"
        internal static var identifier = "com.gkaimakas.ReactiveCoreBluetooth.CBPeripheral.identifier"
        internal static var state = "com.gkaimakas.ReactiveCoreBluetooth.CBPeripheral.state"
        internal static var services = "com.gkaimakas.ReactiveCoreBluetooth.CBPeripheral.services"
        internal static var discovered = "com.gkaimakas.ReactiveCoreBluetooth.CBPeripheral.discovered"
    }
}
