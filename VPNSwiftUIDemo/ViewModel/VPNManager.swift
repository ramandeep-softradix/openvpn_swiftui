import SwiftUI

class VPNManager: ObservableObject {
    @Published var connection = VPNConnection(isConnected: false, selectedCountry: nil, selectedProtocol: .openVPN)
    @Published var connectionStatus: ConnectionStatus = .disconnected {
        didSet {
            saveConnectionStatusToLocalStorage()
        }
    }
    @Published var errorMessage: String?
    
    private let openVPNManagerUtil = OpenVPNManagerUtil.shared
    private var timeoutWorkItem: DispatchWorkItem?
    
    // Define the key for storing the connection status in UserDefaults
    private let connectionStatusKey = "VPNConnectionStatus"
    
    let openVPNCountries = [
        VPNConfiguration(cityName: "Singapore", cityImage: "sg", configurationFilePath: ResourcesStrings.openVPNSingapurConfigPath, configurationFileType: .ovpn,
                         name: "Testing", password: "Testing"),
        VPNConfiguration(cityName: "South-Korea", cityImage: "kr", configurationFilePath: ResourcesStrings.openVPNSouthKoreaConfigPath, configurationFileType: .ovpn,
                         name: "test", password: "test"),
        VPNConfiguration(cityName: "United Kingdom", cityImage: "sh", configurationFilePath: ResourcesStrings.openVPNUnitedKingdomConfigPath, configurationFileType: .ovpn,
                         name: "vpn", password: "vpn"),
        VPNConfiguration(cityName: "Canada", cityImage: "ca", configurationFilePath: ResourcesStrings.openVPNCanadaConfigPath, configurationFileType: .ovpn,
                         name: "vpntest", password: "vpntest"),
        VPNConfiguration(cityName: "Germany", cityImage: "de", configurationFilePath: ResourcesStrings.openVPNGermanyConfigPath, configurationFileType: .ovpn,
                         name: "Germany", password: "Germany"),
    ]
    
    // Define a callback closure
    var onVPNStatusChange: ((ConnectionStatus) -> Void)?
    
    var availableCountries: [VPNConfiguration] {
        switch connection.selectedProtocol {
        case .openVPN:
            return openVPNCountries
        }
    }
    
    init() {
        // Retrieve the connection status from local storage on initialization
        loadConnectionStatusFromLocalStorage()
    }
    
    func toggleConnection() {
        if connection.isConnected {
            disconnect()
        } else {
            if connection.selectedCountry != nil {
                errorMessage = ""
                connectionStatus = .connecting
                connect()
            } else {
                errorMessage = LocalizableStrings.selectCountryFirst
            }
        }
    }
    
    private func connect() {
        timeoutWorkItem?.cancel()
        
        timeoutWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            if self.connectionStatus == .connecting {
                self.disconnect()
                self.errorMessage = LocalizableStrings.connectionTimedOut
            }
        }
        
        if connection.selectedProtocol == .openVPN {
            connectToOpenVPN()
        }
    }
    
    private func disconnect() {
        timeoutWorkItem?.cancel()
        
        if connection.selectedProtocol == .openVPN {
            openVPNManagerUtil.disconnectVPN()
            DispatchQueue.main.async {
                self.connection.isConnected = false
                self.connectionStatus = .disconnected
            }
        }
    }
    
    func onSelectCountry(selecetdCountry: VPNConfiguration) {
        errorMessage = ""
        connection.selectedCountry = selecetdCountry
        print("Selected Country: \(connection.selectedCountry?.cityName ?? "")")
    }
    
    func onTapProtocolSegmentedController() {
        errorMessage = nil // Clear the error message when switching protocols
    }
    
    func connectToOpenVPN() {
        let configurationFileContent = extractVPNConfigurationFile(forResource: connection.selectedCountry?.configurationFilePath ?? "", ofType: connection.selectedCountry?.configurationFileType.rawValue ?? "ovpn") ?? Data()
        
        let login = connection.selectedCountry?.login ?? ""
        let pass = connection.selectedCountry?.password ?? ""
        openVPNManagerUtil.setupVPNStatusListener { status in
            self.connection.isConnected = false
            
            switch status {
            case .disconnected:
                self.connectionStatus = .disconnected
                self.timeoutWorkItem?.cancel() // Cancel the timeout if disconnected
            case .connecting:
                self.connectionStatus = .connecting
            case .connected:
                self.connectionStatus = .connected
                self.connection.isConnected = true
                self.timeoutWorkItem?.cancel() // Cancel the timeout if connected
            case .reconnecting:
                self.connectionStatus = .connecting
            case .disconnecting:
                self.connectionStatus = .disconnecting
            }
        }
        
        openVPNManagerUtil.configureVPN(openVPNConfiguration: configurationFileContent, login: login, pass: pass)
        
        // Schedule the timeout task after 30 seconds
        if let timeoutWorkItem = timeoutWorkItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: timeoutWorkItem)
        }
    }
    
    func dataToString(data: Data) -> String? {
        return String(data: data, encoding: .utf8)
    }
    
    // MARK: - Local Storage
    
    private func saveConnectionStatusToLocalStorage() {
        let isConnected = connectionStatus == .connected
        UserDefaults.standard.set(isConnected, forKey: connectionStatusKey)
    }
    
    private func loadConnectionStatusFromLocalStorage() {
        let isConnected = UserDefaults.standard.bool(forKey: connectionStatusKey)
        if isConnected {
            connectionStatus = .connected
            connection.isConnected = true
        } else {
            connectionStatus = .disconnected
            connection.isConnected = false
        }
    }
}
