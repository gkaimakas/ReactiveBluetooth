//
//  CBCentralManager+ReactiveDelegate.swift
//  FBSnapshotTestCase
//
//  Created by George Kaimakas on 02/03/2018.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

extension CBCentralManager {
    internal class ReactiveDelegate: NSObject, CBCentralManagerDelegate {
        internal let event: Signal<CBCentralManager.DelegateEvent, NoError>
        private let eventObserver: Signal<CBCentralManager.DelegateEvent, NoError>.Observer

        override internal init() {
            (event, eventObserver) = Signal<CBCentralManager.DelegateEvent, NoError>.pipe()
            super.init()
        }

        func centralManagerDidUpdateState(_ central: CBCentralManager) {
            eventObserver.send(value: .didUpdateState(central: central))
        }

        func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
            eventObserver.send(value: .willRestoreState(central: central, dict: dict))
        }

        func centralManager(_ central: CBCentralManager,
                            didDiscover peripheral: CBPeripheral,
                            advertisementData: [String : Any],
                            rssi RSSI: NSNumber) {

            eventObserver.send(value: .didDiscover(central: central,
                                                   peripheral: peripheral,
                                                   advertismentData: CBPeripheral.AdvertismentData.parse(advertisementData),
                                                   RSSI: RSSI))
        }

        func centralManager(_ central: CBCentralManager,
                            didConnect peripheral: CBPeripheral) {

            eventObserver.send(value: .didConnect(central: central,
                                                  peripheral: peripheral,
                                                  error: nil))
        }

        func centralManager(_ central: CBCentralManager,
                            didFailToConnect peripheral: CBPeripheral,
                            error: Error?) {

            eventObserver.send(value: .didConnect(central: central,
                                                  peripheral: peripheral,
                                                  error: error))
        }

        func centralManager(_ central: CBCentralManager,
                            didDisconnectPeripheral peripheral: CBPeripheral,
                            error: Error?) {

            eventObserver.send(value: .didDisconnect(central: central,
                                                     peripheral: peripheral,
                                                     error: error))

        }
    }
}
