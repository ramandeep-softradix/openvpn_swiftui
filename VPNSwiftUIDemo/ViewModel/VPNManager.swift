// VPNManager.swift
import Foundation
import SwiftUI

class VPNManager: ObservableObject {
    @Published var connection = VPNConnection(isConnected: false, selectedCountry: nil, selectedProtocol: .wireGuard)

    private let openVPNManagerUtil = OpenVPNManagerUtil.shared

    func toggleConnection() {
        if connection.isConnected {
            disconnect()
        } else {
            connect()
        }
    }

    private func connect() {
        guard connection.selectedProtocol == .openVPN else {
            // Handle WireGuard connection setup here
            return
        }
        
        let configurationFileContent = "Your OpenVPN config content here" // Replace with actual .ovpn content
        let login = "your_login"
        let pass = "your_password"
        
        openVPNManagerUtil.configureVPN(openVPNConfiguration: configurationFileContent, login: login, pass: pass) { success in
            if success {
                self.openVPNManagerUtil.connectVPN { errorDescription in
                    if let error = errorDescription {
                        print("Error connecting VPN: \(error)")
                    } else {
                        DispatchQueue.main.async {
                            self.connection.isConnected = true
                        }
                    }
                }
            } else {
                print("Failed to save VPN profile.")
            }
        }
    }

    private func disconnect() {
        openVPNManagerUtil.disconnectVPN()
        DispatchQueue.main.async {
            self.connection.isConnected = false
        }
    }
}
