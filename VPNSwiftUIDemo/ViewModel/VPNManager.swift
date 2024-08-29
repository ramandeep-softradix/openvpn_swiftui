import SwiftUI

class VPNManager: ObservableObject {
    @Published var connection = VPNConnection(isConnected: false, selectedCountry: nil, selectedProtocol: .openVPN)
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var errorMessage: String?
    
    private let openVPNManagerUtil = OpenVPNManagerUtil.shared
    private var timeoutWorkItem: DispatchWorkItem?
    
    private let ipSecVPNManager = IPSecVPNManager.shared // Use IPSecVPNManager

    
    // Define your VPN configurations here
    let wireGuardCountries = [
        VPNConfiguration(cityName: "New York", configurationFilePath: ResourcesStrings.wireGuardNYConfigPath, configurationFileType: .conf),
        VPNConfiguration(cityName: "London", configurationFilePath: ResourcesStrings.wireGuardLondonConfigPath, configurationFileType: .conf)
    ]
    
    let openVPNCountries = [
        VPNConfiguration(cityName: "Gloucester, United Kingdom", configurationFilePath: ResourcesStrings.openVPNGloucesterConfigPath, configurationFileType: .ovpn,
                         name: "test", password: "test"),
        VPNConfiguration(cityName: "Angeles, Philippines", configurationFilePath: ResourcesStrings.openVPNAngelesConfigPath, configurationFileType: .ovpn,
                         name: "softradix", password: "softradix"),
        VPNConfiguration(cityName: "Budapest, Hungary", configurationFilePath: ResourcesStrings.openVPnBudapestConfigPath, configurationFileType: .ovpn,
                         name: "softradix", password: "softradix"),
        VPNConfiguration(cityName: "Milan, Italy", configurationFilePath: ResourcesStrings.openVPMilanConfigPath, configurationFileType: .ovpn,
                         name: "softradix", password: "softradix")
    ]
    
    let ikev2Countries = [
        VPNConfiguration(cityName: "San Francisco", configurationFilePath: ResourcesStrings.ikev2SFConfigPath, configurationFileType: .mobileconfig),
        VPNConfiguration(cityName: "Tokyo", configurationFilePath: ResourcesStrings.ikev2TokyoConfigPath, configurationFileType: .mobileconfig)
    ]
    
    let ipsecCountries = [
        VPNConfiguration(cityName: "Berlin", configurationFilePath: ResourcesStrings.ipsecBerlinConfigPath, configurationFileType: .mobileconfig),
        VPNConfiguration(cityName: "Sydney", configurationFilePath: ResourcesStrings.ipsecSydneyConfigPath, configurationFileType: .mobileconfig)
    ]
    
    // Define a callback closure
    var onVPNStatusChange: ((ConnectionStatus) -> Void)?
    
    var availableCountries: [VPNConfiguration] {
        switch connection.selectedProtocol {
        case .wireGuard:
            return wireGuardCountries
        case .openVPN:
            return openVPNCountries
        case .ikev2:
            return ikev2Countries
        case .ipsec:
            return ipsecCountries
        }
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
        } else if connection.selectedProtocol == .wireGuard {
            // Existing WireGuard connection logic...
        } else if connection.selectedProtocol == .ikev2 || connection.selectedProtocol == .ipsec {
            connectToIPSec()
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
        } else if connection.selectedProtocol == .wireGuard {
            // Existing WireGuard disconnection logic...
        } else if connection.selectedProtocol == .ikev2 || connection.selectedProtocol == .ipsec {
            ipSecVPNManager.disconnectVPN()
        }
    }
    
    
    
    func onSelectCountry(selecetdCountry: VPNConfiguration) {
        errorMessage = ""
        connection.selectedCountry = selecetdCountry
        print("Selected Country: \(connection.selectedCountry?.cityName ?? "")")
    }
    
    func onTapProtocolSegmentedController(){
        errorMessage = nil // Clear the error message when switching protocols
    }
    
    func connectToOpenVPN(){
        let configurationFileContent = extractVPNConfigurationFile(forResource: connection.selectedCountry?.configurationFilePath ?? "", ofType: connection.selectedCountry?.configurationFileType.rawValue ?? "ovpn")
        
        guard let configurationFileData = configurationFileContent else {
            errorMessage = LocalizableStrings.failedToLoadConfig
            connectionStatus = .disconnected
            return
        }
        
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
        openVPNManagerUtil.configureVPN(openVPNConfiguration: configurationFileData, login: login, pass: pass)
        
        // Schedule the timeout task after 30 seconds
        if let timeoutWorkItem = timeoutWorkItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: timeoutWorkItem)
        }
    }
    
    private func connectToIPSec() {
           let configurationFileContent = extractVPNConfigurationFile(forResource: connection.selectedCountry?.configurationFilePath ?? "", ofType: connection.selectedCountry?.configurationFileType.rawValue ?? "mobileconfig")
           
           guard let configurationFileData = configurationFileContent else {
               errorMessage = LocalizableStrings.failedToLoadConfig
               connectionStatus = .disconnected
               return
           }
           
           ipSecVPNManager.setupVPNStatusListener { status in
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
               case .disconnecting:
                   self.connectionStatus = .disconnecting
               default:
                   break
               }
           }
           
           ipSecVPNManager.configureVPN(configurationFile: configurationFileData)
           ipSecVPNManager.connectVPN()
           
           if let timeoutWorkItem = timeoutWorkItem {
               DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: timeoutWorkItem)
           }
       }
    
    
}
