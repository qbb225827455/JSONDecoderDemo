//
//  Loan.swift
//  JSONdecoderDemo
//
//  Created by 陳鈺翔 on 2022/8/9.
//

import Foundation

struct LoanDataStore: Codable {
    var loans: [Loan]
}

struct Loan: Hashable, Codable {
    static func == (lhs: Loan, rhs: Loan) -> Bool {
        lhs.name == rhs.name && lhs.use == rhs.use
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(use)
    }
    
    var name: String = ""
    var use: String = ""
    var location: Location
    var amount: Int = 0
    
    struct Location: Codable {
        var country: String = ""
        var geo: Geo
    }
    
    struct Geo: Codable {
        var level: String = ""
        var pairs: String = ""
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case use
        case location
        case amount = "loan_amount"
        
        enum LocationKeys: String, CodingKey {
            case country
            case geo
            
            enum GeoKeys: String, CodingKey {
                case level
                case pairs
            }
        }
    }
    
    init(from decoder: Decoder) throws {
        
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try rootContainer.decode(String.self, forKey: .name)
        use = try rootContainer.decode(String.self, forKey: .use)
        amount = try rootContainer.decode(Int.self, forKey: .amount)
        
        let root_locationContainer = try rootContainer.nestedContainer(keyedBy: CodingKeys.LocationKeys.self, forKey: CodingKeys.location)
        
        let country = try root_locationContainer.decode(String.self, forKey: CodingKeys.LocationKeys.country)
        
        let root_location_geoContainer = try root_locationContainer.nestedContainer(keyedBy: CodingKeys.LocationKeys.GeoKeys.self, forKey: CodingKeys.LocationKeys.geo)
        let level = try root_location_geoContainer.decode(String.self, forKey: CodingKeys.LocationKeys.GeoKeys.level)
        let pairs = try root_location_geoContainer.decode(String.self, forKey: CodingKeys.LocationKeys.GeoKeys.pairs)
        let geo = Geo(level: level, pairs: pairs)
    
        location = Location.init(country: country, geo: geo)
    }
}

