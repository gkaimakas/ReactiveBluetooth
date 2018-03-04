//
//  CBCentralManager+DelegateEvent.swift
//  FBSnapshotTestCase
//
//  Created by George Kaimakas on 02/03/2018.
//

import CoreBluetooth
import Result

extension CBCentralManager {
    internal enum DelegateEvent {
        case didUpdateState(central: CBCentralManager)
        case willRestoreState(central: CBCentralManager, dict: [String: Any])
        case didDiscover(central: CBCentralManager, peripheral: CBPeripheral, advertismentData: Set<CBPeripheral.AdvertismentData>, RSSI: NSNumber)
        case didConnect(central: CBCentralManager, peripheral: CBPeripheral, error: Error?)
        case didDisconnect(central: CBCentralManager, peripheral: CBPeripheral, error: Error?)

        func filter(central: CBCentralManager) -> Bool {
            switch self {
            case .didUpdateState(central: let _central):
                return central == _central
            case .willRestoreState(central: let _central, dict: _):
                return central == _central
            case .didDiscover(central: let _central, peripheral: _, advertismentData: _, RSSI: _):
                return central == _central
            case .didConnect(central: let _central, peripheral: _, error: _):
                return central == _central
            case .didDisconnect(central: let _central, peripheral: _, error: _):
                return central == _central
            }
        }

        func filter(peripheral: CBPeripheral) -> Bool {
            return filter(peripheral: peripheral.identifier)
        }

        func filter(peripheral identifier: UUID) -> Bool {
            switch self {
            case .didUpdateState(central: _),
                 .willRestoreState(central: _, dict: _):
                return false
            case .didDiscover(central: _, peripheral: let _peripheral, advertismentData: _, RSSI: _):
                return identifier.uuidString == _peripheral.identifier.uuidString
            case .didConnect(central: _, peripheral: let _peripheral, error: _):
                return identifier.uuidString == _peripheral.identifier.uuidString
            case .didDisconnect(central: _, peripheral: let _peripheral, error: _):
                return identifier.uuidString == _peripheral.identifier.uuidString
            }
        }

        var didUpdateState: CBCentralManager? {
            switch self {
            case .didUpdateState(let central): return central
            default: return nil
            }
        }

        var willRestoreState: [String: Any]? {
            switch self {
            case .willRestoreState(_ , let dict): return dict
            default: return nil
            }
        }

        var didDiscoverPeripheral: (peripheral: CBPeripheral, advertismentData: Set<CBPeripheral.AdvertismentData>, RSSI: NSNumber)? {
            switch  self {
            case .didDiscover(_ , let peripheral, let advertismentData, let RSSI):
                return (peripheral: peripheral, advertismentData: advertismentData, RSSI: RSSI)
            default:
                return nil
            }
        }

        var didConnect: (peripheral: CBPeripheral, error:Error?)? {
            switch self {
            case .didConnect(central: _, let peripheral, let error):
                return (peripheral: peripheral, error: error)
            default:
                return nil
            }
        }

        var didDisconnect: (peripheral: CBPeripheral, error:Error?)? {
            switch self {
            case .didDisconnect(central: _, let peripheral, let error):
                return (peripheral: peripheral, error: error)
            default:
                return nil
            }
        }
    }
}
