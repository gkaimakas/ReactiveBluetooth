//
//  CBPeripheral+DelegateEvent.swift
//  ReactiveCoreBluetooth
//
//  Created by George Kaimakas on 03/03/2018.
//

import CoreBluetooth

extension CBPeripheral {
    internal enum DelegateEvent {
        case didUpdateName(peripheral: CBPeripheral)
        case didReadRSSI(peripheral: CBPeripheral, RSSI: NSNumber, error: Error?)
        case didDiscoverServices(peripheral: CBPeripheral, error: Error?)
        case didDiscoverIncludedServices(peripheral: CBPeripheral, service: CBService, error: Error?)
        case didDiscoverCharacteristics(peripheral: CBPeripheral, service: CBService, error: Error?)
        case didDiscoverDescriptors(peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?)
        case didUpdateNotificationState(peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?)
        case didWriteValueForCharacteristic(peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?)
        case didWriteValueForDescriptor(peripheral: CBPeripheral, descriptor: CBDescriptor, error: Error?)
        case didUpdateValueForCharacteristic(peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?)
        case didUpdateValueForDescriptor(peripheral: CBPeripheral, descriptor: CBDescriptor, error: Error?)

        func filter(peripheral: CBPeripheral) -> Bool {
            switch self {
            case .didUpdateName(peripheral: let _peripheral):
                return peripheral.identifier == _peripheral.identifier
            case .didReadRSSI(peripheral: let _peripheral, RSSI: _, error: _):
                return peripheral.identifier == _peripheral.identifier
            case .didDiscoverServices(peripheral: let _peripheral, error: _):
                return peripheral.identifier == _peripheral.identifier
            case .didDiscoverIncludedServices(peripheral: let _peripheral, service: _, error: _):
                return peripheral.identifier == _peripheral.identifier
            case .didDiscoverCharacteristics(peripheral: let _peripheral, service: _, error: _):
                return peripheral.identifier == _peripheral.identifier
            case .didDiscoverDescriptors(peripheral: let _peripheral, characteristic: _, error: _):
                return peripheral.identifier == _peripheral.identifier
            case .didUpdateNotificationState(peripheral: let _peripheral, characteristic: _, error: _):
                return peripheral.identifier == _peripheral.identifier
            case .didWriteValueForCharacteristic(peripheral: let _peripheral, characteristic: _, error: _):
                return peripheral.identifier == _peripheral.identifier
            case .didWriteValueForDescriptor(peripheral: let _peripheral, descriptor: _, error: _):
                return peripheral.identifier == _peripheral.identifier
            case .didUpdateValueForCharacteristic(peripheral: let _peripheral, characteristic: _, error: _):
                return peripheral.identifier == _peripheral.identifier
            case .didUpdateValueForDescriptor(peripheral: let _peripheral, descriptor: _, error: _):
                return peripheral.identifier == _peripheral.identifier
            }
        }

        func filter(service: CBService) -> Bool {
            return filter(service: service.uuid)
        }

        func filter(service: CBUUID) -> Bool {
            return filter(service: service.uuidString)
        }

        func filter(service: String) -> Bool {
            switch self {
            case .didDiscoverIncludedServices(peripheral: _, service: let _service, error: _):
                return service == _service.uuid.uuidString
            case .didDiscoverCharacteristics(peripheral: _, service: let _service, error: _):
                return service == _service.uuid.uuidString
            default:
                return false
            }
        }

        func filter(characteristic: CBCharacteristic) -> Bool {
            return filter(characteristic: characteristic.uuid)
        }

        func filter(characteristic: CBUUID) -> Bool {
            return filter(characteristic: characteristic.uuidString)
        }

        func filter(characteristic: String) -> Bool {
            switch self {
            case .didDiscoverDescriptors(peripheral: _, characteristic: let _characteristic, error: _):
                return characteristic == _characteristic.uuid.uuidString
            case .didUpdateNotificationState(peripheral: _, characteristic: let _characteristic, error: _):
                return characteristic == _characteristic.uuid.uuidString
            case .didWriteValueForCharacteristic(peripheral: _, characteristic: let _characteristic, error: _):
                return characteristic == _characteristic.uuid.uuidString
            case .didUpdateValueForCharacteristic(peripheral: _, characteristic: let _characteristic, error: _):
                return characteristic == _characteristic.uuid.uuidString
            default:
                return false
            }
        }

        func filter(descriptor: CBDescriptor) -> Bool {
            return filter(descriptor: descriptor.uuid)
        }

        func filter(descriptor: CBUUID) -> Bool {
            return filter(descriptor: descriptor.uuidString)
        }

        func filter(descriptor: String) -> Bool {
            switch self {
            case .didWriteValueForDescriptor(peripheral: _, descriptor: let _descriptor, error: _):
                return descriptor == _descriptor.uuid.uuidString
            case .didUpdateValueForDescriptor(peripheral: _, descriptor: let _descriptor, error: _):
                return descriptor == _descriptor.uuid.uuidString
            default:
                return false
            }
        }

        var didUpdateName: CBPeripheral? {
            switch self {
            case .didUpdateName(let peripheral):
                return peripheral
            default:
                return nil
            }
        }

        var didReadRSSI: (RSSI: NSNumber, error: Error?)? {
            switch self {
            case .didReadRSSI( _, let RSSI, let error):
                return (RSSI: RSSI, error: error)
            default:
                return nil
            }
        }

        var didDiscoverServices: (peripheral: CBPeripheral, error: Error?)? {
            switch self {
            case .didDiscoverServices(let peripheral, let error):
                return (peripheral: peripheral, error: error)
            default:
                return nil
            }
        }

        var didDiscoverIncludedServices: (service: CBService, error: Error?)? {
            switch self {
            case .didDiscoverIncludedServices(peripheral: _, let service, let error):
                return (service: service, error: error)
            default:
                return nil
            }
        }

        var didDiscoverCharacteristics: (service: CBService, error: Error?)? {
            switch self {
            case .didDiscoverCharacteristics(peripheral: _, let service, let error):
                return (service: service, error: error)
            default:
                return nil
            }
        }

        var didDiscoverDescriptors: (characteristic: CBCharacteristic, error: Error?)? {
            switch self {
            case .didDiscoverDescriptors(_, let characteristic, let error):
                return (characteristic: characteristic, error: error)
            default:
                return nil
            }
        }

        var didUpdateNotificationState: (characteristic: CBCharacteristic, error: Error?)? {
            switch self {
            case .didUpdateNotificationState(_, let characteristic, let error):
                return (characteristic: characteristic, error: error)
            default:
                return nil
            }
        }

        var didWriteValueForCharacteristic: (characteristic: CBCharacteristic, error: Error?)? {
            switch self {
            case .didWriteValueForCharacteristic(_, let characteristic, let error):
                return (characteristic: characteristic, error: error)
            default:
                return nil
            }
        }

        var didWriteValueForDescriptor: (descriptor: CBDescriptor, error: Error?)? {
            switch self {
            case .didWriteValueForDescriptor(_, let descriptor, let error):
                return (descriptor: descriptor, error: error)
            default:
                return nil
            }
        }

        var didUpdateValueForCharacteristic: (characteristic: CBCharacteristic, error: Error?)? {
            switch self {
            case .didUpdateValueForCharacteristic(_, let characteristic, let error):
                return (characteristic: characteristic, error: error)
            default:
                return nil
            }
        }

        var didUpdateValueForDescriptor: (descriptor: CBDescriptor, error: Error?)? {
            switch self {
            case .didUpdateValueForDescriptor(_, let descriptor, let error):
                return (descriptor: descriptor, error: error)
            default:
                return nil
            }
        }
    }
}
