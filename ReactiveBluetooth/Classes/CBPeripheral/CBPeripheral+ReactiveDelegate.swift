//
//  CBPeripheral+ReactiveDelegate.swift
//  FBSnapshotTestCase
//
//  Created by George Kaimakas on 02/03/2018.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

extension CBPeripheral {
    internal class ReactiveDelegate: NSObject, CBPeripheralDelegate {
        internal let event: Signal<CBPeripheral.DelegateEvent, NoError>
        private let eventObserver: Signal<CBPeripheral.DelegateEvent, NoError>.Observer

        override internal init() {
            (event, eventObserver) = Signal<CBPeripheral.DelegateEvent, NoError>.pipe()
            super.init()
        }

        func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
            eventObserver.send(value: .didUpdateName(peripheral: peripheral))
        }

        func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
            eventObserver.send(value: .didReadRSSI(peripheral: peripheral,
                                                    RSSI: RSSI,
                                                    error: error))
        }

        func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            eventObserver.send(value: .didDiscoverServices(peripheral: peripheral,
                                                            error: error))
        }

        func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
            eventObserver.send(value: .didDiscoverIncludedServices(peripheral: peripheral,
                                                                    service: service,
                                                                    error: error))
        }

        func peripheral(_ peripheral: CBPeripheral,
                        didDiscoverCharacteristicsFor service: CBService,
                        error: Error?) {
            eventObserver.send(value: .didDiscoverCharacteristics(peripheral: peripheral,
                                                                   service: service,
                                                                   error: error))
        }

        func peripheral(_ peripheral: CBPeripheral,
                        didDiscoverDescriptorsFor characteristic: CBCharacteristic,
                        error: Error?) {
            eventObserver.send(value: .didDiscoverDescriptors(peripheral: peripheral,
                                                               characteristic: characteristic,
                                                               error: error))
        }

        func peripheral(_ peripheral: CBPeripheral,
                        didUpdateNotificationStateFor characteristic: CBCharacteristic,
                        error: Error?) {

            eventObserver.send(value: .didUpdateNotificationState(peripheral: peripheral,
                                                                   characteristic: characteristic,
                                                                   error: error))
        }

        func peripheral(_ peripheral: CBPeripheral,
                        didWriteValueFor characteristic: CBCharacteristic,
                        error: Error?) {

            eventObserver.send(value: .didWriteValueForCharacteristic(peripheral: peripheral,
                                                                       characteristic: characteristic,
                                                                       error: error))

        }

        func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
            eventObserver.send(value: .didWriteValueForDescriptor(peripheral: peripheral,
                                                                   descriptor: descriptor,
                                                                   error: error))
        }

        func peripheral(_ peripheral: CBPeripheral,
                        didUpdateValueFor characteristic: CBCharacteristic,
                        error: Error?) {

            eventObserver.send(value: .didUpdateValueForCharacteristic(peripheral: peripheral,
                                                                        characteristic: characteristic,
                                                                        error: error))

        }

        func peripheral(_ peripheral: CBPeripheral,
                        didUpdateValueFor descriptor: CBDescriptor,
                        error: Error?) {
            eventObserver.send(value: .didUpdateValueForDescriptor(peripheral: peripheral,
                                                                    descriptor: descriptor,
                                                                    error: error))
        }
        
    }
}
