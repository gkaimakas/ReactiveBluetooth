//
//  CentralManager+ InitializationOption.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 21/01/2018.
//

import CoreBluetooth

extension CentralManager {
    public enum InitializationOption: Equatable, Hashable {
        public static func ==(lhs: CentralManager.InitializationOption, rhs: CentralManager.InitializationOption) -> Bool {
            switch (lhs, rhs) {
            case (.showPowerAlert(let a), .showPowerAlert(let b)): return a == b
            case (.restoreIdentifier(let a), .restoreIdentifier(let b)): return a == b
            default: return false
            }
        }

        public var hashValue: Int {
            switch self {
            case .showPowerAlert(_): return 1_000
            case .restoreIdentifier(_): return 1_000_000
            }
        }

        public var key: String {
            switch self {
            case .showPowerAlert(_): return CBCentralManagerOptionShowPowerAlertKey
            case .restoreIdentifier(_): return CBCentralManagerOptionRestoreIdentifierKey
            }
        }

        public var value: Any {
            switch  self {
            case .showPowerAlert(let value): return value as Any
            case .restoreIdentifier(let value): return value as Any
            }
        }

        case showPowerAlert(Bool)
        case restoreIdentifier(String)
    }
}

extension Set where Element == CentralManager.InitializationOption {
    public func merge() -> [String: Any] {
        return reduce([String: Any]() ) { (partialResult, item) -> [String: Any] in
            var result = partialResult
            result[item.key] = item.value
            return result
        }
    }
}
