//
//  AppDelegate.swift
//  VPNSwiftUIDemo
//
//  Created by Softradix on 22/08/24.
//

import UIKit
import OpenVPNXor

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let openvpnPacketTunnelIdentifier = "com.softradix.VPNSwiftUIDemo.VPNNetworkExtension"
    let appGroupIdentifier = "group.com.softradix.VPNSwiftUIDemo"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Custom initialization code here
        OpenVPNManager.setup(openvpnPacketTunnelIdentifier: openvpnPacketTunnelIdentifier, appGroupIdentifier: appGroupIdentifier)

        
        
        return true
    }
    
    // Other UIApplicationDelegate methods
}
