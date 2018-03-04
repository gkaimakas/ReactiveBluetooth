//
//  CBPeripheral+CBCentralManager.swift
//  ReactiveCoreBluetooth
//
//  Created by George Kaimakas on 04/03/2018.
//

import CoreBluetooth

extension CBPeripheral {
    internal var centralManager: CBCentralManager? {
        get {
            return objc_getAssociatedObject(self,
                                            &CBPeripheral.Associations.centralManager) as? CBCentralManager
        }

        set {
            objc_setAssociatedObject(self,
                                     &CBPeripheral.Associations.centralManager,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
