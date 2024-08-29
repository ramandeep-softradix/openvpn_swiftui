import NetworkExtension
import OpenVPNXor
import os.log

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!
    /// Logs the view cycles like viewDidLoad.
    static let viewCycle = OSLog(subsystem: subsystem, category: "PacketTunnel")
}

class PacketTunnelProvider: OpenVPNPacketTunnelProvider {

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        /// Add code here to start the process of connecting the tunnel.
        os_log("startTunnel!", log: OSLog.viewCycle, type: .info)
        super.startTunnel(options: options, completionHandler: completionHandler)
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        /// Add code here to start the process of stopping the tunnel.
        super.stopTunnel(with: reason, completionHandler: completionHandler)
    }

    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        super.handleAppMessage(messageData, completionHandler: completionHandler)
    }
}
