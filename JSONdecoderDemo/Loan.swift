//
//  Loan.swift
//  JSONdecoderDemo
//
//  Created by 陳鈺翔 on 2022/8/9.
//

import Foundation

struct Loan: Hashable, Codable {
    var name: String = ""
    var use: String = ""
    var country: String = ""
    var amount: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case name
        case use
        case country = "location"
        case amount = "loan_amount"
    }
    
    enum LoacationKeys: String, CodingKey {
        case country
    }
    
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try values.decode(String.self, forKey: .name)
        use = try values.decode(String.self, forKey: .use)
        amount = try values.decode(Int.self, forKey: .amount)
        
        let location = try values.nestedContainer(keyedBy: LoacationKeys.self, forKey: .country)
        country = try location.decode(String.self, forKey: .country)
    }
}

struct LoanDataStore: Codable {
    var loans: [Loan]
}
