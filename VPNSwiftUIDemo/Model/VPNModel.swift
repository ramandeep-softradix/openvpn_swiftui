// VPNModel.swift
import Foundation

enum VPNProtocol: String {
    case wireGuard = "WireGuard"
    case openVPN = "OpenVPN"
    case ikev2 = "IKEv2"
    case ipsec = "IPsec"
}

enum ConnectionStatus {
    case disconnected
    case connecting
    case connected
    case reconnecting
    case disconnecting
}


struct VPNConnection {
    var isConnected: Bool
    var selectedCountry: VPNConfiguration?
    var selectedProtocol: VPNProtocol
}

enum ConfigurationFileType: String, Codable {
    case ovpn = "ovpn"
    case conf = "conf"
    case mobileconfig = "mobileconfig"
}

struct VPNConfiguration: Codable, Identifiable {
    let id = UUID()
    let cityName: String
    let configurationFilePath: String
    let configurationFileType: ConfigurationFileType
    let login: String?
    let password: String?

    // Coding Keys
    enum CodingKeys: String, CodingKey {
        case cityName, configurationFilePath, configurationFileType, name, password
    }

    // Encode to JSON
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cityName, forKey: .cityName)
        try container.encode(configurationFilePath, forKey: .configurationFilePath)
        try container.encode(configurationFileType.rawValue, forKey: .configurationFileType)
        try container.encode(login, forKey: .name)
        try container.encode(password, forKey: .password)
    }

    // Decode from JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cityName = try container.decode(String.self, forKey: .cityName)
        configurationFilePath = try container.decode(String.self, forKey: .configurationFilePath)
        configurationFileType = try container.decode(ConfigurationFileType.self, forKey: .configurationFileType)
        login = try container.decodeIfPresent(String.self, forKey: .name)
        password = try container.decodeIfPresent(String.self, forKey: .password)
    }

    // Default initializer
    init(cityName: String, configurationFilePath: String, configurationFileType: ConfigurationFileType, name: String? = nil, password: String? = nil) {
        self.cityName = cityName
        self.configurationFilePath = configurationFilePath
        self.configurationFileType = configurationFileType
        self.login = name
        self.password = password
    }
}
