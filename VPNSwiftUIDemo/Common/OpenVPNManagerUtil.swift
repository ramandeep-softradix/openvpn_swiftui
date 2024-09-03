// OpenVPNManager.swift
import Foundation
import OpenVPNXor

class OpenVPNManagerUtil : VPNManagerDelegate {
    static let shared = OpenVPNManagerUtil()
    
    // VPN Status
    enum VPNStatus {
        case invalid, disconnected, connecting, connected, reasserting, disconnecting
    }
    
    var onVPNStatusChange: ((ConnectionStatus) -> Void)?
    var vpnStatus: VPNStatus = .invalid
    var vpnStatusLabel:String = ""
    
    private init() {
    }
    
    func configureVPN(openVPNConfiguration: Data, login: String, pass: String) {
        print("Configuring VPN with config: \(openVPNConfiguration.base64EncodedString())")
        OpenVPNManager.shared.configureVPN(openVPNConfiguration: openVPNConfiguration, login: login, pass: pass) { success in
            DispatchQueue.main.async {
                if success {
                    print("VPN Profile saved successfully.")
                    self.connectVPN()
                } else {
                    print("Error saving VPN profile.")
                }
            }
        }
    }
    
    func connectVPN() -> Void {
        // Implement VPN connection logic here
        print("Connecting VPN...")
        // Simulate connection
        
        
        OpenVPNManager.shared.connectVPN { errorDescription in
            if errorDescription != nil {
                self.vpnStatus = .invalid
            } else {
                self.vpnStatus = .connecting
            }
        }
    }
    
    func disconnectVPN() {
        // Implement VPN disconnection logic here
        print("Disconnecting VPN...")
        // Simulate disconnection
        OpenVPNManager.shared.disconnectVPN()
        self.vpnStatusLabel = "VPN Disconnected"
        self.vpnStatus = .disconnected
    }
    
    // Method to set up a listener for VPN status changes
    func setupVPNStatusListener(callback: @escaping (ConnectionStatus) -> Void) {
        OpenVPNManager.shared.onVPNStatusChange = { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .invalid, .disconnected:
                    print("VPN Disconnected")
                    callback(.disconnected)
                case .connecting:
                    print("VPN Connecting...")
                    callback(.connecting)
                case .connected:
                    print("VPN Connected")
                    callback(.connected)
                case .reasserting:
                    print("VPN Reconnecting...")
                    callback(.reconnecting)
                case .disconnecting:
                    print("VPN Disconnecting...")
                    callback(.disconnecting)
                }
            }
        }
    }

    // Example delegate methods

    func VpnManagerConnectionFailed(error: VPNCollectionErrorType, localizedDescription: String) {
        print("VPN connection failed: \(localizedDescription)")
    }
    
    func VpnManagerConnected() {
        print("VPN connected successfully.")
    }
    
    func VpnManagerDisconnected() {
        print("VPN disconnected.")
    }
    
    func VpnManagerProfileSaved() {
        print("VPN profile saved successfully.")
    }
    
    func VpnManagerPacketTransmitted(with bitrate: Bitrate) {
        print("Network Traffic Statistics - \(NetworkTrafficStatistics.formBitrateString(with: bitrate))")
    }
    
    func VpnManagerLogs(log: String?) {
        if let log = log {
            print("VPN Log: \(log)")
        }
    }
}
