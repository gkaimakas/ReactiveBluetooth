//
//  CBCentralManager+AdvertismentData.swift
//  ReactiveCoreBluetooth
//
//  Created by George Kaimakas on 03/03/2018.
//

import CoreBluetooth

extension CBPeripheral {
    public enum AdvertismentData: Equatable, Hashable {
        public static func parse(_ advertismentData: [String: Any]) -> Set<AdvertismentData> {
            return Set(advertismentData
                .map { (key, value) -> AdvertismentData in

                    if key == CBAdvertisementDataLocalNameKey,
                        let name = value as? String {

                        return .localName(name)
                    }

                    if key == CBAdvertisementDataManufacturerDataKey,
                        let data = value as? Data {

                        return .manufacturerData(data)
                    }

                    if key == CBAdvertisementDataServiceDataKey,
                        let data = value as? [CBUUID: Data] {

                        return .serviceData(data)
                    }

                    if key == CBAdvertisementDataServiceUUIDsKey,
                        let uuids = value as? [UUID] {

                        return .serviceUUIDs(uuids)
                    }

                    if key == CBAdvertisementDataOverflowServiceUUIDsKey,
                        let services = value as? [CBUUID] {

                        return .overflowServiceUUIDs(services)
                    }

                    if key == CBAdvertisementDataTxPowerLevelKey,
                        let powerLevel = value as? NSNumber {

                        return .TxPowerLevel(powerLevel)
                    }

                    if key == CBAdvertisementDataIsConnectable,
                        let number = value as? NSNumber {

                        return .isConnectable(number.boolValue)
                    }

                    if key == CBAdvertisementDataSolicitedServiceUUIDsKey,
                        let uuids = value as? [CBUUID] {

                        return .solicitedServiceUUIDs(uuids)
                    }

                    return .custom(key: key, value: value)
                })
        }

        public static func ==(lhs: AdvertismentData, rhs: AdvertismentData) -> Bool {
            switch (lhs, rhs) {
            case (.localName(let a), .localName(let b)): return a == b
            case (.manufacturerData(let a), .manufacturerData(let b)): return a == b
            case (.serviceData(let a), .serviceData(let b)): return a == b
            case (.serviceUUIDs(let a), .serviceUUIDs(let b)): return a == b
            case (.overflowServiceUUIDs(let a), .overflowServiceUUIDs(let b)): return a == b
            case (.TxPowerLevel(let a), .TxPowerLevel(let b)): return a == b
            case (.isConnectable(let a), .isConnectable(let b)): return a == b
            case (.solicitedServiceUUIDs(let a), .solicitedServiceUUIDs(let b)): return a == b
            case (.custom(let keyA, _), .custom(let keyB, _)): return keyA == keyB
            default:
                return false
            }
        }
        
        case localName(String)
        case manufacturerData(Data)
        case serviceData([CBUUID: Data])
        case serviceUUIDs([UUID])
        case overflowServiceUUIDs([CBUUID])
        case TxPowerLevel(NSNumber)
        case isConnectable(Bool)
        case solicitedServiceUUIDs([CBUUID])
        case custom(key: String, value: Any)

        public var hashValue: Int {
            switch self {
            case .localName(let name): return name.hashValue
            case .manufacturerData(let data): return data.hashValue
            case .serviceData(let data): return data.reduce(0, { (result, item) -> Int in
                return result + item.key.hashValue + item.value.hashValue
            })
            case .serviceUUIDs(let list): return list.reduce(0, { (result, uuid) -> Int in
                return result + uuid.hashValue
            })
            case .overflowServiceUUIDs(let list): return list.reduce(0, { (result, uuid) -> Int in
                return result + uuid.hashValue
            })
            case .TxPowerLevel(let number): return number.hashValue
            case .isConnectable(let value): return value.hashValue
            case .solicitedServiceUUIDs(let list): return list.reduce(0, { (result, uuid) -> Int in
                return result + uuid.hashValue
            })
            case .custom(let key, _): return key.hashValue
            }

        }
    }
}
