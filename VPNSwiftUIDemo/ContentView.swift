// ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var vpnManager = VPNManager()
    @State private var selectedCountry: String? = nil

    let countries = ["United States", "United Kingdom", "Canada", "Germany", "Australia"]
    let protocols = ["WireGuard", "OpenVPN"]

    var body: some View {
        NavigationView {
            VStack {
                Text("VPN App")
                    .font(.largeTitle)
                    .padding()
                
                // Protocol Picker
                Picker("Select Protocol", selection: $vpnManager.connection.selectedProtocol) {
                    ForEach(protocols, id: \.self) { protocolName in
                        Text(protocolName).tag(VPNProtocol(rawValue: protocolName) ?? .wireGuard)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Connect Button
                Button(action: {
                    vpnManager.toggleConnection()
                }) {
                    Text(vpnManager.connection.isConnected ? "Disconnect" : "Connect")
                        .font(.title)
                        .padding()
                        .background(vpnManager.connection.isConnected ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                // Country List
                List(countries, id: \.self) { country in
                    HStack {
                        Text(country)
                        Spacer()
                        if selectedCountry == country {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedCountry = country
                        vpnManager.connection.selectedCountry = country
                    }
                }
                .listStyle(InsetGroupedListStyle())
                
                Spacer()
            }
            .navigationTitle("VPN Home")
        }
    }
}

#Preview {
    ContentView()
}
