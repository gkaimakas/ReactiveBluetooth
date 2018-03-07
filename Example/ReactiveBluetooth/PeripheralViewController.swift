//
//  PeripheralViewController.swift
//  ReactiveBluetooth_Example
//
//  Created by George Kaimakas on 07/03/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import CoreBluetooth
import ReactiveBluetooth
import ReactiveCocoa
import ReactiveSwift
import Result
import UIKit

public final class PeripheralViewController: UIViewController {
    var viewModel: CBPeripheral!
    var toggleConnectiom: Action<Void, CBPeripheral, NSError>!

    override public func viewDidLoad() {
        super.viewDidLoad()

        let enableToggleConnection = viewModel
            .reactive
            .state
            .map({ state -> Bool in
                switch state {
                case .connected, .disconnected: return true
                case .connecting, .disconnecting: return false
                }
            })

        toggleConnectiom = Action<Void, CBPeripheral, NSError>(execute: { _ -> SignalProducer<CBPeripheral, NSError> in

                                                        switch self.viewModel.state {
                                                        case .connected:
                                                            return self.viewModel.reactive.cancelPeripheralConnection()
                                                        case .disconnected:
                                                            return self.viewModel.reactive.connect()
                                                        default: return SignalProducer.empty
                                                        }
        })

        print(viewModel.responds(to: #keyPath(CBPeripheral.state)))

        navigationItem.title = viewModel.name ?? "Not Available"
        navigationItem.prompt = viewModel.identifier.uuidString
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Connect", style: .plain, target: nil, action: nil)

        navigationItem.rightBarButtonItem!.reactive.title <~ viewModel
            .reactive
            .state
            .producer
            .map { state -> String in
                switch state {
                case .connected: return "Disconnect"
                case .connecting: return "Connecting..."
                case .disconnected: return "Connect"
                case .disconnecting: return "Disconnecting..."
                }
        }
        navigationItem.rightBarButtonItem!.reactive.pressed = CocoaAction(toggleConnectiom)
        navigationItem.reactive.prompt <~ viewModel.reactive.identifier.map { $0.uuidString }
    }
}
