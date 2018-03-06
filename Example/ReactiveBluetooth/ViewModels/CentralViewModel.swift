//
//  CentralViewModel.swift
//  ReactiveBluetooth_Example
//
//  Created by George Kaimakas on 06/03/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import CoreBluetooth
import Foundation
import ReactiveBluetooth
import ReactiveCocoa
import ReactiveSwift
import Result

public final class CentralViewModel {
    private let _central: CBCentralManager
    private let _discoveredPeripherals: MutableProperty<[CBPeripheral]>

    public let discoveredPeripherals: Property<[CBPeripheral]>

    public let isScanning: Property<Bool>
    public let startScan: Action<Void, CBPeripheral, NoError>
    public let stopScan: Action<Void, Void, NoError>

    init(central: CBCentralManager) {
        self._central = central
        self._discoveredPeripherals = MutableProperty([])
        self.discoveredPeripherals = Property(_discoveredPeripherals)
        self.isScanning = central.reactive.isScanning

        startScan = Action(enabledIf: central.reactive.isScanning.negate(), execute: { _ in
            return central
                .reactive
                .scanForPeripherals(withServices: nil, options: [.allowDuplicates(false)])
                .map { $0.peripheral }
        })

        stopScan = Action(enabledIf: central.reactive.isScanning, execute: { _  in
            return central
                .reactive
                .stopScan()
        })

        _discoveredPeripherals <~ startScan
            .values
            .map { [unowned self] peripheral -> [CBPeripheral] in
                if self._discoveredPeripherals.value.contains(where: { $0 == peripheral }) == false {
                    return self._discoveredPeripherals.value + [peripheral]
                }
                return self._discoveredPeripherals.value
            }
            .skipRepeats { $0 == $1 }
    }
}
