//
//  VehicleModels.swift
//  AllVehicleModelsAPI
//
//  Created by lijia xu on 8/4/21.
//

import Foundation

struct VehicleModelsTopLevelObject: Codable {
    let count: Int
    let results: [VehicleModel]
    
    enum CodingKeys: String, CodingKey {
        case count = "Count"
        case results = "Results"
    }

}

struct VehicleModel: Codable {
    let makeName: String
    let modelID: Int
    let modelName: String
    
    enum CodingKeys: String, CodingKey {
        case modelID = "Model_ID"
        case makeName = "Make_Name"
        case modelName = "Model_Name"
    }

    
}
