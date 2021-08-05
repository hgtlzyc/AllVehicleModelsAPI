//
//  VehicleModelsControler.swift
//  AllVehicleModelsAPI
//
//  Created by lijia xu on 8/4/21.
//

import Foundation

enum ModelsError: LocalizedError {
    case idOutOfRange
    case unableToGenerateURLWithString(String)
    case thrownError(Error,Int?)
    case unableToDecodeData(Error)
    case nilData
    
    var errorDescription: String? {
        switch self {
        case .idOutOfRange:
            return "id out of range"
        case .unableToGenerateURLWithString(_):
            return "URL not valid"
        case let .thrownError(err, code):
            return "code: \(String(describing: code)) \(err.localizedDescription)"
        case .unableToDecodeData(let err):
            return "unable to decode data \(err)"
        case .nilData:
            return "no data received from server"
        }
        
    }
    
}//End Of ModelsError


class VehicleModelsControler {
    
    static let lowerBound = kAppConstants.VehicleIDBounds.lowerInclusiveBound
    static let upperBound = kAppConstants.VehicleIDBounds.upperInclusiveBound
    
    private static var tasks = [URLSessionDataTask]()
    
    static func cancelAllPendingTasks(){
        tasks.forEach{$0.cancel()}
        tasks = []
    }
    
    
    static func fetchModelsFor(_ id: Int, completion: @escaping (Result<[VehicleModel],ModelsError>) -> Void) {
        
        guard id >= lowerBound && id <= upperBound else { return completion(.failure(.idOutOfRange)) }
        
        let baseString = "https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMakeId/"
        let baseURL = URL(string: baseString)
        let urlWithMake = baseURL?.appendingPathComponent("\(id)")
        
        guard let urlString = urlWithMake?.absoluteString else { return completion(.failure(.unableToGenerateURLWithString(baseString) )) }
        
        var urlComponents = URLComponents(string: urlString)
        let queryItem = URLQueryItem(name: "format", value: "json")
        urlComponents?.queryItems = [queryItem]
        
        guard let finalURL = urlComponents?.url else { return completion(.failure(.unableToGenerateURLWithString(urlString))) }
        
        let task = URLSession.shared.dataTask(with: finalURL) { data, response, error in
            
            if let error = error , let resp = response as? HTTPURLResponse {
                completion(.failure(.thrownError(error,resp.statusCode)))
                return
            } else if let error = error{
                completion(.failure(.thrownError(error, nil)))
                return
            }
            
            guard let data = data else { return completion(.failure(.nilData)) }
            
            do {
                let vehicleModelsTopLevel = try JSONDecoder().decode(VehicleModelsTopLevelObject.self, from: data)
                completion(.success(vehicleModelsTopLevel.results))
            } catch let err {
                completion(.failure(.unableToDecodeData(err)))
            }
            
        }
        tasks.append(task)
        task.resume()
        
        
    }//End Of func
    
    
}//End Of VehicleModelsControler
