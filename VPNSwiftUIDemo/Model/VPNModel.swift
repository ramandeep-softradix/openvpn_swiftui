// VPNModel.swift
import Foundation

enum VPNProtocol: String {
    case openVPN = "OpenVPN"
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
    var id: UUID
    let uuid: String
    let cityName: String
    let cityImage: String
    let configurationFilePath: String
    let configurationFileType: ConfigurationFileType
    let login: String?
    let password: String?

    // Coding Keys
    enum CodingKeys: String, CodingKey {
        case id, uuid, cityName, cityImage, configurationFilePath, configurationFileType, login, password
    }

    // Encode to JSON
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(cityName, forKey: .cityName)
        try container.encode(cityImage, forKey: .cityImage)
        try container.encode(configurationFilePath, forKey: .configurationFilePath)
        try container.encode(configurationFileType.rawValue, forKey: .configurationFileType)
        try container.encode(login, forKey: .login)
        try container.encode(password, forKey: .password)
    }

    // Decode from JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        uuid = try container.decode(String.self, forKey: .uuid)
        cityName = try container.decode(String.self, forKey: .cityName)
        cityImage = try container.decode(String.self, forKey: .cityImage)
        configurationFilePath = try container.decode(String.self, forKey: .configurationFilePath)
        configurationFileType = try container.decode(ConfigurationFileType.self, forKey: .configurationFileType)
        login = try container.decodeIfPresent(String.self, forKey: .login)
        password = try container.decodeIfPresent(String.self, forKey: .password)
    }

    // Default initializer
    init(id: UUID = UUID(), uuid: String, cityName: String, cityImage: String, configurationFilePath: String, configurationFileType: ConfigurationFileType, login: String? = nil, password: String? = nil) {
        self.id = id
        self.uuid = uuid
        self.cityName = cityName
        self.cityImage = cityImage
        self.configurationFilePath = configurationFilePath
        self.configurationFileType = configurationFileType
        self.login = login
        self.password = password
    }
}
