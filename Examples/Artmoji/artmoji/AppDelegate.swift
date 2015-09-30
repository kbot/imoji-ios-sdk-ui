//
//  AppDelegate.swift
//  artmoji
//
//  Created by Alex Hoang on 9/24/15.
//  Copyright (c) 2015 Imoji. All rights reserved.
//

import UIKit
import ImojiSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {
        ImojiSDK.sharedInstance().setClientId(NSUUID(UUIDString: "748cddd4-460d-420a-bd42-fcba7f6c031b")!, apiToken: "U2FsdGVkX1/yhkvIVfvMcPCALxJ1VHzTt8FPZdp1vj7GIb+fsdzOjyafu9MZRveo7ebjx1+SKdLUvz8aM6woAw==")

        return true
    }
}

