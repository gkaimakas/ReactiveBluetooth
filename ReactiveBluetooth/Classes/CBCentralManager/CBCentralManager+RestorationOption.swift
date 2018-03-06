//
//  CBCentralManager+RestorationOption.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 06/03/2018.
//

import CoreBluetooth

extension CBCentralManager {
    public enum RestorationOption: Equatable, Hashable {
        public static func ==(lhs: CBCentralManager.RestorationOption, rhs: CBCentralManager.RestorationOption) -> Bool {
            switch (lhs, rhs) {
            case (.peripherals(let a), .peripherals(let b)): return a == b
            case (.scanServices(let a), .scanServices(let b)): return a == b
            case (.scanOptions(let a), .scanOptions(let b)): return a == b
            default: return false
            }
        }

        public static func parse(dictionary: [String: Any]) -> [RestorationOption] {
            return dictionary
                .map { (key, value) -> RestorationOption? in
                    if key == CBCentralManagerRestoredStatePeripheralsKey, let value = value as? [CBPeripheral] {
                        return .peripherals(value)
                    }

                    if key == CBCentralManagerRestoredStateScanServicesKey, let value = value as? [CBUUID] {
                        return .scanServices(value)
                    }

                    if key == CBCentralManagerRestoredStateScanOptionsKey,
                        let value = value as? [String: Any] {
                        return .scanOptions(Set(CBCentralManager.ScanOption.parse(dictionary: value)))
                    }

                    return nil
                }
                .filter { $0 != nil }
                .map { $0! }
        }

        case peripherals([CBPeripheral])
        case scanServices([CBUUID])
        case scanOptions(Set<CBCentralManager.ScanOption>)

        public var hashValue: Int {
            switch self {
            case .peripherals(_): return 3_000
            case .scanServices(_): return 3_000_000
            case .scanOptions(_): return 3_000_000_000
            }
        }

        public var key: String {
            switch self {
            case .peripherals(_): return CBCentralManagerRestoredStatePeripheralsKey
            case .scanServices(_): return CBCentralManagerRestoredStateScanServicesKey
            case .scanOptions(_): return CBCentralManagerRestoredStateScanOptionsKey
            }
        }

        public var value: Any {
            switch self {
            case .peripherals(let value): return value as Any
            case .scanServices(let value): return value as Any
            case .scanOptions(let value): return value as Any
            }
        }
    }
}
