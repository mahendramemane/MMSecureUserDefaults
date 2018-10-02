//
//  AppDelegate.swift
//  MMUserDefaultsSQLite
//
//  Created by Mahendra Memane on 30/09/18.
//  Copyright © 2018 Mahendra Memane. All rights reserved.
//

import UIKit

struct Employee: Codable {
    let age:Int
    let name:String
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }



}

