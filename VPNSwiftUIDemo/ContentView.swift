import SwiftUI

struct ContentView: View {
    @StateObject private var vpnManager = VPNManager()
    @State private var showAlert = false
    @State private var alertMessage: String?

//    let protocols = ["WireGuard", "OpenVPN"]
//    let protocols = ["OpenVPN"]
    
    // Add IKEv2 and IPsec to the list of protocols
      let protocols = ["WireGuard", "OpenVPN", "IKEv2", "IPsec"]

    var body: some View {
        NavigationView {
            VStack {
                Text(LocalizableStrings.vpnAppTitle)
                    .font(.largeTitle)
                    .padding()
                
                // Protocol Picker
                Picker(LocalizableStrings.selectProtocol, selection: $vpnManager.connection.selectedProtocol) {
                    ForEach(protocols, id: \.self) { protocolName in
                        Text(protocolName).tag(VPNProtocol(rawValue: protocolName) ?? .wireGuard)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: vpnManager.connection.selectedProtocol) { _ in
                    vpnManager.onTapProtocolSegmentedController()
                }
                
                // Connect Button
                Button(action: {
                    vpnManager.toggleConnection()
                }) {
                    Text(buttonTitle())
                        .font(.title)
                        .padding()
                        .background(buttonBackgroundColor())
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(vpnManager.connectionStatus == .connecting)
                
                // Display Error Message
                if let errorMessage = vpnManager.errorMessage, !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                // Country List
                List(vpnManager.availableCountries) { country in
                    HStack {
                        Text(country.cityName)
                        Spacer()
                        if vpnManager.connection.selectedCountry?.id == country.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if vpnManager.connectionStatus == .connected {
                            // Show an alert if the VPN is connected
                            alertMessage = LocalizableStrings.changeLocationAlert
                            showAlert = true
                        } else {
                            vpnManager.onSelectCountry(selecetdCountry: country)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                
                Spacer()
            }
            .navigationTitle(LocalizableStrings.vpnAppTitle)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(LocalizableStrings.actionRequired),
                    message: Text(alertMessage ?? LocalizableStrings.errorOccurred),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private func buttonTitle() -> String {
        switch vpnManager.connectionStatus {
        case .connecting:
            return LocalizableStrings.connecting
        case .connected:
            return LocalizableStrings.disconnect
        case .disconnected:
            return LocalizableStrings.connect
        case .reconnecting:
            return LocalizableStrings.reconnecting
        case .disconnecting:
            return LocalizableStrings.disconnecting
        }
    }

    private func buttonBackgroundColor() -> Color {
        switch vpnManager.connectionStatus {
        case .connecting:
            return Color.orange
        case .connected:
            return Color.red
        case .disconnected:
            return Color.green
        case .reconnecting:
            return Color.yellow
        case .disconnecting:
            return Color.gray
        }
    }
}
