// VPNModel.swift
import Foundation

enum VPNProtocol: String {
    case wireGuard = "WireGuard"
    case openVPN = "OpenVPN"
}

struct VPNConnection {
    var isConnected: Bool
    var selectedCountry: String?
    var selectedProtocol: VPNProtocol
}
