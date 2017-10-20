//
//  PeripheralObserver.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 19/10/2017.
//

import CoreBluetooth
import Foundation
import ReactiveSwift
import Result

public class PeripheralObserver: NSObject {
	public let didUpdateName: Signal<UpdatedName, NoError>
	fileprivate let didUpdateNameObserver: Signal<UpdatedName, NoError>.Observer

	public let didReadRSSI: Signal<Result<ReadRSSI, ReadRSSIError>, NoError>
	fileprivate let didReadRSSIObserver: Signal<Result<ReadRSSI, ReadRSSIError>, NoError>.Observer

	public let didDiscoverService: Signal<Result<DiscoveredService, DiscoveredServiceError>, NoError>
	fileprivate let didDiscoverServiceObserver: Signal<Result<DiscoveredService, DiscoveredServiceError>, NoError>.Observer

	public let didDiscoverCharacteristic: Signal<Result<DiscoveredCharacteristic, DiscoveredCharacteristicError>, NoError>
	fileprivate let didDiscoverCharacteristicObserver: Signal<Result<DiscoveredCharacteristic, DiscoveredCharacteristicError>, NoError>.Observer

	public let didUpdateNotificationState: Signal<Result<UpdatedNotificationState, UpdatedNotificationStateError>, NoError>
	fileprivate let didUpdateNotificationStateObserver: Signal<Result<UpdatedNotificationState, UpdatedNotificationStateError>, NoError>.Observer

	public let didWriteValue: Signal<Result<WrittenValue, WrittenValueError>, NoError>
	fileprivate let didWriteValueObserver: Signal<Result<WrittenValue, WrittenValueError>, NoError>.Observer

	public let didUpdateValue: Signal<Result<UpdatedValue, UpdatedValueError>, NoError>
	fileprivate let didUpdateValueObserver: Signal<Result<UpdatedValue, UpdatedValueError>, NoError>.Observer

	public override init() {
		(didUpdateName, didUpdateNameObserver) = Signal.pipe()
		(didReadRSSI, didReadRSSIObserver) = Signal.pipe()
		(didDiscoverService, didDiscoverServiceObserver) = Signal.pipe()
		(didDiscoverCharacteristic, didDiscoverCharacteristicObserver) = Signal.pipe()
		(didUpdateNotificationState, didUpdateNotificationStateObserver) = Signal.pipe()
		(didWriteValue, didWriteValueObserver) = Signal.pipe()
		(didUpdateValue, didUpdateValueObserver) = Signal.pipe()

		super.init()
	}
}

extension PeripheralObserver: CBPeripheralDelegate {

	public func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
		didUpdateNameObserver.send(value: UpdatedName(peripheral: peripheral))
	}

	public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
		if let error = error as NSError? {
			let result = Result<ReadRSSI, ReadRSSIError>(error: ReadRSSIError(peripheral: peripheral, error: error))
			didReadRSSIObserver.send(value: result)
			return
		}

		let readRSSI = ReadRSSI(peripheral: peripheral,
		                        RSSI: RSSI)
		let result = Result<ReadRSSI, ReadRSSIError>(value: readRSSI)
		didReadRSSIObserver.send(value: result)
	}

	public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {

		if let error = error as NSError? {
			let result = Result<DiscoveredService, DiscoveredServiceError>(error: DiscoveredServiceError(peripheral: peripheral, error: error))
			didDiscoverServiceObserver.send(value: result)
			return
		}

		if let services = peripheral.services {
			services
				.map { DiscoveredService(peripheral: peripheral,
				                         service: $0)
				}
				.map { Result<DiscoveredService, DiscoveredServiceError>(value: $0) }
				.forEach { didDiscoverServiceObserver.send(value: $0) }
		}

	}

	public func peripheral(_ peripheral: CBPeripheral,
	                       didDiscoverCharacteristicsFor service: CBService,
	                       error: Error?) {

		if let error = error as NSError? {
			let discoveredCharacteristicError = DiscoveredCharacteristicError(peripheral: peripheral,
			                                                                  service: service,
			                                                                  error: error)
			let result = Result<DiscoveredCharacteristic, DiscoveredCharacteristicError>(error: discoveredCharacteristicError)
			didDiscoverCharacteristicObserver.send(value: result)
			return
		}

		if let characteristics = service.characteristics {
			characteristics
				.map { DiscoveredCharacteristic(peripheral: peripheral,
				                                service: service,
				                                characteristic: $0)
				}
				.map { Result<DiscoveredCharacteristic, DiscoveredCharacteristicError>(value: $0) }
				.forEach { didDiscoverCharacteristicObserver.send(value: $0) }
		}
	}

	public func peripheral(_ peripheral: CBPeripheral,
	                       didUpdateNotificationStateFor characteristic: CBCharacteristic,
	                       error: Error?) {

		if let error = error as NSError? {
			let updatedNotificationStateError = UpdatedNotificationStateError(peripheral: peripheral,
			                                                                  characteristic: characteristic,
			                                                                  error: error)
			let result = Result<UpdatedNotificationState, UpdatedNotificationStateError>(error: updatedNotificationStateError)
			didUpdateNotificationStateObserver.send(value: result)
			return
		}

		let updatedNotificationState = UpdatedNotificationState(peripheral: peripheral,
		                                                        characteristic: characteristic)
		let result = Result<UpdatedNotificationState, UpdatedNotificationStateError>(value: updatedNotificationState)
		didUpdateNotificationStateObserver.send(value: result)
	}

	public func peripheral(_ peripheral: CBPeripheral,
	                       didWriteValueFor characteristic: CBCharacteristic,
	                       error: Error?) {

		if let error = error as NSError? {
			let writtenValueError = WrittenValueError(peripheral: peripheral,
			                                          characteristic: characteristic,
			                                          error: error)

			let result = Result<WrittenValue, WrittenValueError>(error: writtenValueError)
			didWriteValueObserver.send(value: result)
			return
		}

		let writtenValue = WrittenValue(peripheral: peripheral,
		                                characteristic: characteristic)
		let result = Result<WrittenValue, WrittenValueError>(value: writtenValue)
		didWriteValueObserver.send(value: result)

	}

	public func peripheral(_ peripheral: CBPeripheral,
	                       didUpdateValueFor characteristic: CBCharacteristic,
	                       error: Error?) {

		if let error = error as NSError? {
			let updatedValueError = UpdatedValueError(peripheral: peripheral,
			                                          characteristic: characteristic,
			                                          error: error)
			let result = Result<UpdatedValue, UpdatedValueError>(error: updatedValueError)
			didUpdateValueObserver.send(value: result)
			return
		}

		let updatedValue = UpdatedValue(peripheral: peripheral,
		                                characteristic: characteristic)

		let result = Result<UpdatedValue, UpdatedValueError>(value: updatedValue)

		didUpdateValueObserver.send(value: result)

	}
}
