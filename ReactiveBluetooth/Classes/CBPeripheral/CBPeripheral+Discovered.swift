//
//  CBPeripheral+Discovered.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 04/03/2018.
//

import CoreBluetooth
import ReactiveCocoa
import ReactiveSwift
import Result

extension CBPeripheral {
    public class Discovered {
        public let advertismentData: Signal<Set<CBPeripheral.AdvertismentData>, NoError>
        public let RSSI: Signal<NSNumber, NoError>

        internal let advertismentDataObserver: Signal<Set<CBPeripheral.AdvertismentData>, NoError>.Observer
        internal let RSSIObserver: Signal<NSNumber, NoError>.Observer

        public init() {
            (advertismentData, advertismentDataObserver) = Signal.pipe()
            (RSSI, RSSIObserver) = Signal.pipe()
        }
    }
}

extension CBPeripheral.Discovered {
    internal class Cache: NSObject {
        private let mapTable: NSMapTable<CBPeripheral, CBPeripheral>
        private let queue: DispatchQueue

        override init() {
            mapTable = NSMapTable<CBPeripheral, CBPeripheral>.weakToWeakObjects()
            queue = DispatchQueue(label: "com.gkaimakas.ReactiveCoreBluetooth.CBPeripheral.discovered.cache", attributes: .concurrent)
        }

        func set(object: CBPeripheral) {
            queue.async(flags: .barrier) {
                self.mapTable.setObject(object, forKey: object)
            }
        }

        func object(for key: CBPeripheral) -> CBPeripheral? {
            var result: CBPeripheral?
            queue.sync {
                result = self.mapTable.object(forKey: key)
            }
            return result
        }
    }
}

extension Reactive where Base == CBPeripheral.Discovered.Cache {
    var  update: BindingTarget<(peripheral: CBPeripheral, advertismentData: Set<CBPeripheral.AdvertismentData>, RSSI: NSNumber)> {
        return makeBindingTarget { (cache, update) in
            if let peripheral = cache.object(for: update.peripheral) {

                peripheral.reactive.discovered.advertismentDataObserver.send(value: update.advertismentData)
                peripheral.reactive.discovered.RSSIObserver.send(value: update.RSSI)

            } else {
                cache.set(object: update.peripheral)
                update.peripheral.reactive.discovered.advertismentDataObserver.send(value: update.advertismentData)
                update.peripheral.reactive.discovered.RSSIObserver.send(value: update.RSSI)
            }
        }
    }
}
