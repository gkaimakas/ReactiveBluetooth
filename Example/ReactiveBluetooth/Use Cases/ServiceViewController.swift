//
//  ServiceViewController.swift
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

final class ServiceViewController: UIViewController {
    var viewModel: CBService!
    var characteristics: Property<[CBCharacteristic]>!
    var includedServices: Property<[CBService]>!

    @IBOutlet weak var tableView: UITableView!
    var fetchCharacteristics: Action<Void, Void, NSError>!
    var fetchIncludedServices: Action<Void, Void, NSError>!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.reactive.prompt <~ viewModel
            .reactive
            .isPrimary
            .producer
            .map({ $0 ? "isPrimary: yes": "isPrimary: no" })

        navigationItem.title = viewModel.uuid.uuidString

        tableView.dataSource = self
        tableView.delegate = self

        characteristics = viewModel
            .reactive
            .characteristics
            .map({ Array($0) })

        includedServices = viewModel
            .reactive
            .includedServices
            .map({ Array($0) })
        
        fetchCharacteristics = Action<Void, Void, NSError>(execute: { _ -> SignalProducer<Void, NSError> in
            return self.viewModel
                .reactive
                .discoverCharacteristics(nil)
                .map { _ in return () }
        })

        fetchIncludedServices = Action<Void, Void, NSError>(execute: { _ -> SignalProducer<Void, NSError> in
            return self.viewModel
                .reactive
                .discoverIncludedServices(nil)
                .map { _ in return () }
        })

        fetchCharacteristics
            .values
            .observeValues {
                self.tableView.reloadData()
        }

        fetchIncludedServices
            .values
            .observeValues {
                self.tableView.reloadData()
        }

    }
}

extension ServiceViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return characteristics.value.count
        }

        if section == 1 {
            return includedServices.value.count
        }

        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            let object = characteristics.value[indexPath.item]
            cell.textLabel?.text = object.uuid.uuidString
            cell.accessoryType = .disclosureIndicator
            return cell
        }

        if indexPath.section == 1 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            let object = includedServices.value[indexPath.item]
            cell.textLabel?.text = object.uuid.uuidString
            cell.accessoryType = .disclosureIndicator
            return cell
        }

        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension ServiceViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let view = ActionSectionView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 64))
            view.titleLabel.text = "Characteristics"
            view.actionButton.setTitle("Discover", for: .normal)
            view.actionButton.setTitle("Please wait...", for: .disabled)
            view.actionButton.reactive.action = CocoaAction(fetchCharacteristics)
            return view
        }

        if section == 1 {
            let view = ActionSectionView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 64))
            view.titleLabel.text = "Included Services"
            view.actionButton.setTitle("Discover", for: .normal)
            view.actionButton.setTitle("Please wait...", for: .disabled)
            view.actionButton.reactive.action = CocoaAction(fetchIncludedServices)
            return view
        }

        return nil
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64
    }
}
