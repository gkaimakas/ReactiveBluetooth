//
//  CBCharacteristic+Associations.swift
//  Pods
//
//  Created by George Kaimakas on 04/03/2018.
//

import CoreBluetooth

extension CBCharacteristic {
    internal class Associations {
        internal static var value = "com.gkaimakas.ReactiveCoreBluetooth.CBCharacteristic.value"
        internal static var descriptors = "com.gkaimakas.ReactiveCoreBluetooth.CBCharacteristic.descriptors"
        internal static var properties = "com.gkaimakas.ReactiveCoreBluetooth.CBCharacteristic.properties"
        internal static var isNotifying = "com.gkaimakas.ReactiveCoreBluetooth.CBCharacteristic.isNotifying"
    }
}
