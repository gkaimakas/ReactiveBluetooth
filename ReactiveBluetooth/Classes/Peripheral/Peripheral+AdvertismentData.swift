//
//  Peripheral+AdvertismentData.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 22/01/2018.
//

import CoreBluetooth

extension Peripheral {
    public enum AdvertismentData: Hashable {
        public var hashValue: Int {
            return key.hashValue
        }

        public static func ==(lhs: Peripheral.AdvertismentData, rhs: Peripheral.AdvertismentData) -> Bool {
            switch (lhs, rhs) {
            case (.localName(let a), .localName(let b)): return a == b
            case (.manufacturerData(let a), .manufacturerData(let b)): return a == b
            case (.serviceData(let a), .serviceData(let b)): return a == b
            case (.serviceUUIDs(let a), .serviceUUIDs(let b)): return a == b
            case (.overflowServiceUUIDs(let a), .overflowServiceUUIDs(let b)): return a == b
            case (.TxPowerLevel(let a), .TxPowerLevel(let b)): return a == b
            case (.isConnectable(let a), .isConnectable(let b)): return a == b
            case (.solicitedServiceUUIDs(let a), .solicitedServiceUUIDs(let b)): return a == b
            default: return false
            }
        }

        public static func parse(dictionary: [String: Any]) -> [AdvertismentData] {
            return dictionary
                .map { (key, value) -> AdvertismentData? in
                    if key == CBAdvertisementDataLocalNameKey, let result = value as? String {
                        return AdvertismentData.localName(result)
                    }

                    if key == CBAdvertisementDataManufacturerDataKey, let result = value as? Data {
                        return AdvertismentData.manufacturerData(result)
                    }

                    if key == CBAdvertisementDataServiceDataKey, let result = value as? [CBUUID: Data] {
                        return AdvertismentData.serviceData(result)
                    }

                    if key == CBAdvertisementDataServiceUUIDsKey, let result = value as? [CBUUID] {
                        return AdvertismentData.serviceUUIDs(result)
                    }

                    if key == CBAdvertisementDataOverflowServiceUUIDsKey, let result = value as? [CBUUID] {
                        return AdvertismentData.overflowServiceUUIDs(result)
                    }

                    if key == CBAdvertisementDataTxPowerLevelKey, let result = value as? NSNumber {
                        return AdvertismentData.TxPowerLevel(result)
                    }

                    if key == CBAdvertisementDataIsConnectable, let result = value as? Bool {
                        return AdvertismentData.isConnectable(result)
                    }

                    if key == CBAdvertisementDataSolicitedServiceUUIDsKey, let result = value as? [CBUUID] {
                        return AdvertismentData.solicitedServiceUUIDs(result)
                    }

                    return nil
                }
                .filter { $0 != nil }
                .map { $0! }
        }


        public var key: String {
            switch self {
            case .localName: return CBAdvertisementDataLocalNameKey
            case .manufacturerData: return CBAdvertisementDataManufacturerDataKey
            case .serviceData: return CBAdvertisementDataServiceDataKey
            case .serviceUUIDs: return CBAdvertisementDataServiceUUIDsKey
            case .overflowServiceUUIDs: return CBAdvertisementDataOverflowServiceUUIDsKey
            case .TxPowerLevel: return CBAdvertisementDataTxPowerLevelKey
            case .isConnectable: return CBAdvertisementDataIsConnectable
            case .solicitedServiceUUIDs: return CBAdvertisementDataSolicitedServiceUUIDsKey
            }
        }

        case localName(String)
        case manufacturerData(Data)
        case serviceData([CBUUID: Data])
        case serviceUUIDs([CBUUID])
        case overflowServiceUUIDs([CBUUID])
        case TxPowerLevel(NSNumber)
        case isConnectable(Bool)
        case solicitedServiceUUIDs([CBUUID])
    }
}
