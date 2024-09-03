import SwiftUI

/// Manages VPN connection and status.
class VPNManager: ObservableObject {
    // MARK: - Published Properties
    
    @Published var connection = VPNConnection(isConnected: false, selectedCountry: nil, selectedProtocol: .openVPN)
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let openVPNManagerUtil = OpenVPNManagerUtil.shared
    private var timeoutWorkItem: DispatchWorkItem?
    
    // MARK: - VPN Configuration
    
    /// List of available VPN countries and their configurations.
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
    
    // MARK: - Callbacks
    
    /// Callback closure for VPN status changes.
    var onVPNStatusChange: ((ConnectionStatus) -> Void)?
    
    // MARK: - Computed Properties
    
    /// Returns available countries based on the selected VPN protocol.
    var availableCountries: [VPNConfiguration] {
        switch connection.selectedProtocol {
        case .openVPN:
            return openVPNCountries
        }
    }
    
    // MARK: - Initializer
    
    init() {
        setupVPNStatusListener()
    }
    
    // MARK: - Public Methods
    
    /// Toggles the VPN connection based on current connection status.
    func toggleConnection() {
        if connection.isConnected {
            disconnect()
        } else {
            if connection.selectedCountry != nil {
                errorMessage = nil
                connectionStatus = .connecting
                connect()
            } else {
                errorMessage = LocalizableStrings.selectCountryFirst
            }
        }
    }
    
    /// Handles the selection of a VPN country.
    func onSelectCountry(selectedCountry: VPNConfiguration) {
        errorMessage = nil
        connection.selectedCountry = selectedCountry
        print("Selected Country: \(connection.selectedCountry?.cityName ?? "")")
    }
    
    /// Clears the error message when switching protocols.
    func onTapProtocolSegmentedController() {
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    
    /// Connects to the selected VPN protocol.
    private func connect() {
        // Cancel any existing timeout work item
        timeoutWorkItem?.cancel()
        
        // Create a new timeout work item
        timeoutWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            if self.connectionStatus == .connecting {
                self.disconnect()
                self.errorMessage = LocalizableStrings.connectionTimedOut
            }
        }
        
        // Connect based on the selected VPN protocol
        if connection.selectedProtocol == .openVPN {
            connectToOpenVPN()
        }
    }
    
    /// Disconnects from the VPN.
    private func disconnect() {
        // Cancel any existing timeout work item
        timeoutWorkItem?.cancel()
        
        if connection.selectedProtocol == .openVPN {
            openVPNManagerUtil.disconnectVPN()
            DispatchQueue.main.async {
                self.connection.isConnected = false
                self.connectionStatus = .disconnected
            }
        }
    }
    
    /// Configures and connects to OpenVPN using the selected country's configuration.
    private func connectToOpenVPN() {
        let configurationFileContent = extractVPNConfigurationFile(
            forResource: connection.selectedCountry?.configurationFilePath ?? "",
            ofType: connection.selectedCountry?.configurationFileType.rawValue ?? "ovpn"
        ) ?? Data()
        
        let login = connection.selectedCountry?.login ?? ""
        let pass = connection.selectedCountry?.password ?? ""
        
        // Setup VPN status listener
        setupVPNStatusListener()
        
        // Configure VPN
        openVPNManagerUtil.configureVPN(openVPNConfiguration: configurationFileContent, login: login, pass: pass)
        
        // Schedule the timeout task after 30 seconds
        if let timeoutWorkItem = timeoutWorkItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: timeoutWorkItem)
        }
    }
    
    /// Sets up the VPN status listener.
    private func setupVPNStatusListener() {
        openVPNManagerUtil.setupVPNStatusListener { [weak self] status in
            guard let self = self else { return }
            self.connection.isConnected = false
            switch status {
            case .disconnected:
                self.connectionStatus = .disconnected
                self.timeoutWorkItem?.cancel()
            case .connecting:
                self.connectionStatus = .connecting
            case .connected:
                self.connectionStatus = .connected
                self.connection.isConnected = true
                self.timeoutWorkItem?.cancel()
            case .reconnecting:
                self.connectionStatus = .connecting
            case .disconnecting:
                self.connectionStatus = .disconnecting
            }
            // Call the status change callback if provided
            self.onVPNStatusChange?(self.connectionStatus)
        }
    }

  
}
