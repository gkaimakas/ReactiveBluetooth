//
//  CBService+Reactive.swift
//  ReactiveCoreBluetooth
//
//  Created by George Kaimakas on 04/03/2018.
//

import CoreBluetooth
import Foundation
import ReactiveCocoa
import ReactiveSwift
import Result

extension Reactive where Base: CBService {
    public var isPrimary: Property<Bool> {
        guard let isPrimary = objc_getAssociatedObject(base, &CBService.Associations.isPrimary) as? Property<Bool> else {
            let isPrimary = Property(value: base.isPrimary)

            objc_setAssociatedObject(base,
                                     &CBService.Associations.isPrimary,
                                     isPrimary,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            return isPrimary

        }
        return isPrimary
    }

    public var characteristics: Property<Set<CBCharacteristic>> {
        guard let characteristics = objc_getAssociatedObject(base, &CBService.Associations.characteristics) as? Property<Set<CBCharacteristic>> else {
            let characteristics = Property(initial: Set(),
                                           then: producer(forKeyPath: #keyPath(CBService.characteristics))
                                            .filterMap { $0 as? [CBCharacteristic] }
                                            .map { Set($0) })

            objc_setAssociatedObject(base,
                                     &CBService.Associations.characteristics,
                                     characteristics,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            return characteristics

        }
        return characteristics
    }

    public var includedServices: Property<Set<CBService>> {
        guard let includedServices = objc_getAssociatedObject(base, &CBService.Associations.includedServices) as? Property<Set<CBService>> else {
            let includedServices = Property(initial: Set(),
                                            then: producer(forKeyPath: #keyPath(CBService.includedServices))
                                                .filterMap { $0 as? [CBService] }
                                                .map { Set($0) })

            objc_setAssociatedObject(base,
                                     &CBService.Associations.includedServices,
                                     includedServices,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            return includedServices

        }
        return includedServices
    }

    /// Discovers the specified included services of a service.

    public func discoverIncludedServices(_ includedServiceUUIDs: [CBUUID]?) -> SignalProducer<CBService, NSError> {
        return base
            .peripheral
            .reactive
            .discoverIncludedServices(includedServiceUUIDs, for: base)
    }


    /// Discovers the specified characteristics of a service.

    public func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?) -> SignalProducer<CBService, NSError> {
        return base
            .peripheral
            .reactive
            .discoverCharacteristics(characteristicUUIDs, for: base)
    }
}
