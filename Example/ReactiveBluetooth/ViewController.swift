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

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private var viewModel: CentralViewModel!
    public var dataSource: Property<[CBPeripheral]>!
    public var serialDisposable = SerialDisposable()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        viewModel = inject(CentralViewModel.self)

        dataSource = viewModel.discoveredPeripherals

        viewModel
            .isScanning
            .producer
            .startWithValues { value in
                print(value)
        }

//        serialDisposable.inner = viewModel
//            .startScan
//            .apply()
//            .take(until: SignalProducer.timer(interval: DispatchTimeInterval.seconds(10), on: QueueScheduler.main)
//                .take(first: 1)
//                .map { _ in return  () }
//            )
//            .start()

        viewModel.discoveredPeripherals
            .producer
            .startWithValues { _ in
                self.tableView.reloadData()
        }

        tableView.dataSource = self

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
                            .take(until: SignalProducer.timer(interval: DispatchTimeInterval.seconds(20), on: QueueScheduler.main)
                                .take(first: 1)
                                .map { _ in return  () }
                            )
                            .map({ _ in return ()})
                            .flatMapError({ _ in return SignalProducer.empty })
                    }
            }
        }

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "scan", style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem?.reactive.pressed = CocoaAction(toggleScan)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let peripheral = viewModel.discoveredPeripherals.value[indexPath.item]

        cell.textLabel!.text = peripheral.name ?? peripheral.identifier.uuidString
        return cell
    }
}
