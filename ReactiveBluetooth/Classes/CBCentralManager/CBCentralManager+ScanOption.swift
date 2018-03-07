//
//  CBCentralManager+ScanOption.swift
//  FBSnapshotTestCase
//
//  Created by George Kaimakas on 02/03/2018.
//

import CoreBluetooth
import Foundation

extension CBCentralManager {
    public enum ScanOption: Equatable, Hashable {
        public static func ==(lhs: ScanOption, rhs: ScanOption) -> Bool {
            switch (lhs, rhs) {
            case (.allowDuplicates(let a), .allowDuplicates(let b)): return a == b
            case (.solicitedServices(let a), .solicitedServices(let b)): return a == b
            default: return false
            }
        }

        public static func parse(dictionary: [String: Any]) -> [ScanOption] {
            return dictionary
                .map { (key, value) -> ScanOption? in
                    if key == CBCentralManagerScanOptionAllowDuplicatesKey, let value = value as? Bool {
                        return ScanOption.allowDuplicates(value)
                    }

                    if key == CBCentralManagerScanOptionSolicitedServiceUUIDsKey, let value = value as? [CBUUID] {
                        return ScanOption.solicitedServices(value)
                    }

                    return nil
                }
                .filter { $0 != nil }
                .map { $0! }
        }

        public var hashValue: Int {
            switch self {
            case .allowDuplicates(_): return 1_000
            case .solicitedServices(_): return 10_000
            }
        }

        public var key: String {
            switch self {
            case .allowDuplicates(_): return CBCentralManagerScanOptionAllowDuplicatesKey
            case .solicitedServices(_): return CBCentralManagerScanOptionSolicitedServiceUUIDsKey
            }
        }

        public var value: Any {
            switch self {
            case .allowDuplicates(let value): return value as Any
            case .solicitedServices(let uuids): return uuids as Any
            }
        }

        case allowDuplicates(Bool)
        case solicitedServices([CBUUID])
    }
}

extension Set where Element == CBCentralManager.ScanOption {
    public func merge() -> [String: Any] {

        return reduce([String: Any]() ) { (partialResult, item) -> [String: Any] in
            var result = partialResult
            result[item.key] = item.value
            return result
        }
    }
}
