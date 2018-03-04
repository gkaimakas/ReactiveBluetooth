//
//  CBCentralManager+Associations.swift
//  FBSnapshotTestCase
//
//  Created by George Kaimakas on 02/03/2018.
//

import CoreBluetooth

extension CBCentralManager {
    internal class Associations {
        internal static var delegate = "com.gkaimakas.ReactiveCoreBluetooth.CBCentralManager.delegate"
        internal static var isScanning = "com.gkaimakas.ReactiveCoreBluetooth.CBCentralManager.isScanning"
        internal static var state = "com.gkaimakas.ReactiveCoreBluetooth.CBCentralManager.state"
        internal static var didStopScan = "com.gkaimakas.ReactiveCoreBluetooth.CBCentralManager.didStopScan"
    }
}
