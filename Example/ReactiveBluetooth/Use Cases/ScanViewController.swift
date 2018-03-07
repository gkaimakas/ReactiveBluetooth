//
//  ViewController.swift
//  ReactiveBluetooth
//
//  Created by gkaimakas on 03/04/2018.
//  Copyright (c) 2018 gkaimakas. All rights reserved.
//

import CoreBluetooth
import ReactiveBluetooth
import ReactiveCocoa
import ReactiveSwift
import Result
import UIKit

class ScanViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private var viewModel: CentralViewModel!
    public var dataSource: Property<[CBPeripheral]>!
    public var serialDisposable = SerialDisposable()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        viewModel = inject(CentralViewModel.self)

        dataSource = viewModel.discoveredPeripherals

        viewModel.discoveredPeripherals
            .producer
            .startWithValues { _ in
                self.tableView.reloadData()
        }

        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(PeripheralOverviewCell.nib, forCellReuseIdentifier: PeripheralOverviewCell.identifier)

        let toggleScan = Action<Void, Void, NoError> { _ -> SignalProducer<Void, NoError> in
            return self.viewModel
                .isScanning
                .producer
                .take(first: 1)
                .flatMap(.latest) { isScanning -> SignalProducer<Void, NoError> in
                    if isScanning == true {
                        return self.viewModel
                            .stopScan
                            .apply()
                            .flatMapError({ _ in return SignalProducer.empty })
                    } else {
                        return self.viewModel
                            .startScan
                            .apply()
                            .take(until: SignalProducer.timer(interval: DispatchTimeInterval.seconds(10), on: QueueScheduler.main)
                                .take(first: 1)
                                .map { _ in return  () }
                            )
                            .map({ _ in return ()})
                            .flatMapError({ _ in return SignalProducer.empty })
                    }
            }
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Scan", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem?.reactive.pressed = CocoaAction(toggleScan)
        navigationItem.title = "ReactiveBluetooth"
        navigationItem.backBarButtonItem?.title = ""

        navigationItem.reactive.prompt <~ viewModel
            .isScanning
            .producer
            .map { return $0 ? "Scanning..." : nil }
            .take(during: reactive.lifetime)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "PeripheralViewController",
            let viewController = segue.destination as? PeripheralViewController,
            let peripheral = sender as? CBPeripheral {

            viewController.viewModel = peripheral
        }
    }
}

extension ScanViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = dataSource.value[indexPath.item].name ?? "Not Available"
        cell.detailTextLabel?.text = dataSource.value[indexPath.item].identifier.uuidString
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = dataSource.value[indexPath.item]
        performSegue(withIdentifier: "PeripheralViewController", sender: peripheral)
    }
}

extension ScanViewController: UITableViewDelegate {
}
