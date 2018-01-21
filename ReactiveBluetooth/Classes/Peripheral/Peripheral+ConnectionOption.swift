//
//  Peripheral+ConnectionOption.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 21/01/2018.
//

import CoreBluetooth

extension Peripheral {
    public enum ConnectionOption: Equatable, Hashable {
        public static func ==(lhs: Peripheral.ConnectionOption, rhs: Peripheral.ConnectionOption) -> Bool {
            switch (lhs, rhs){
            case (.notifyOnConnection(let a), .notifyOnConnection(let b)): return a == b
            case (.notifyOnDisconnection(let a), .notifyOnDisconnection(let b)): return a == b
            case (.notifyOnNotification(let a), .notifyOnNotification(let b)): return a == b
            default: return false
            }
        }

        public var hashValue: Int {
            switch self {
            case .notifyOnConnection(_): return 1_000
            case .notifyOnDisconnection(_): return 1_000_000
            case .notifyOnNotification(_): return 1_000_000_000
            }
        }

        public var key: String {
            switch self {
            case .notifyOnConnection(_): return CBConnectPeripheralOptionNotifyOnConnectionKey
            case .notifyOnDisconnection(_): return CBConnectPeripheralOptionNotifyOnDisconnectionKey
            case .notifyOnNotification(_): return CBConnectPeripheralOptionNotifyOnNotificationKey
            }
        }

        public var value: Any {
            switch self {
            case .notifyOnConnection(let value): return value as Any
            case .notifyOnDisconnection(let value): return value as Any
            case .notifyOnNotification(let value): return value as Any
            }
        }

        case notifyOnConnection(Bool)
        case notifyOnDisconnection(Bool)
        case notifyOnNotification(Bool)
    }
}

extension Set where Element == Peripheral.ConnectionOption {
    public func merge() -> [String: Any] {

        return reduce([String: Any]() ) { (partialResult, item) -> [String: Any] in
            var result = partialResult
            result[item.key] = item.value
            return result
        }
    }
}
