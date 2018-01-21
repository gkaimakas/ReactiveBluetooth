//
//  CentralManager+RestoredState.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 22/01/2018.
//

import CoreBluetooth

extension CentralManager {
    public enum StateRestorationOption {
        public static func parse(dictionary: [String: Any], central: CentralManager) -> [StateRestorationOption] {
            return dictionary
                .map { (key, value) -> StateRestorationOption? in
                    if key == CBCentralManagerRestoredStatePeripheralsKey, let value = value as? [CBPeripheral] {
                        return StateRestorationOption.peripherals(value.map({ Peripheral(peripheral: $0, central: central)}))
                    }

                    if key == CBCentralManagerRestoredStateScanServicesKey, let value = value as? [CBUUID] {
                        return StateRestorationOption.scanServices(value)
                    }

                    if key == CBCentralManagerRestoredStateScanOptionsKey, let value = value as? [String: Any] {
                        return StateRestorationOption.scanOptions(CentralManager.ScanOption.parse(dictionary: value))
                    }

                    return nil
                }
                .filter { $0 != nil }
                .map { $0! }
        }

        case peripherals([Peripheral])
        case scanServices([CBUUID])
        case scanOptions([ScanOption])
    }
}
