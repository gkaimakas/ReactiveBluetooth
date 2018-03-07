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
    var fetchServices: Action<Void, Void, NSError>!
    public var dataSource: Property<[CBService]>!

    @IBOutlet weak var tableView: UITableView!
    override public func viewDidLoad() {
        super.viewDidLoad()

        dataSource = viewModel
            .reactive
            .services
            .map({ Array($0) })

        tableView.dataSource = self
        tableView.delegate = self

        toggleConnectiom = Action<Void, CBPeripheral, NSError>(execute: { _ -> SignalProducer<CBPeripheral, NSError> in

                                                        switch self.viewModel.state {
                                                        case .connected:
                                                            return self.viewModel.reactive.cancelPeripheralConnection()
                                                        case .disconnected:
                                                            return self.viewModel.reactive.connect()
                                                        default: return SignalProducer.empty
                                                        }
        })

        fetchServices = Action<Void, Void, NSError>(execute: { _ -> SignalProducer<Void, NSError> in
            return self.viewModel
                .reactive
                .discoverServices(nil)
                .map { _ in return () }
        })

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

        dataSource
            .producer
            .on(value: { _ in self.tableView.reloadData() })
            .start()
    }
}

extension PeripheralViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.value.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = dataSource.value[indexPath.item].uuid.uuidString
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension PeripheralViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = ActionSectionView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 64))
        view.titleLabel.text = "Services"
        view.actionButton.setTitle("Discover", for: .normal)
        view.actionButton.setTitle("Please wait...", for: .disabled)
        view.actionButton.reactive.action = CocoaAction(fetchServices)
        return view
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64
    }


}
