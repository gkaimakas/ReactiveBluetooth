//
//  AppDelegate.swift
//  ReactiveBluetooth
//
//  Created by gkaimakas on 10/20/2017.
//  Copyright (c) 2017 gkaimakas. All rights reserved.
//

import AsyncDisplayKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let asyncNavigationController = UINavigationController(rootViewController: ScanNodeController())

        window = UIWindow()
        window?.backgroundColor = .white
        window?.rootViewController = asyncNavigationController
        window?.makeKeyAndVisible()

        ASDisableLogging()

        return true
    }


}

