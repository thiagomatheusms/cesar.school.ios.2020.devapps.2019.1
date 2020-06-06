//
//  REST.swift
//  Carangas
//
//  Created by Thiago Matheus on 29/05/20.
//  Copyright © 2020 CESAR School. All rights reserved.
//

import Foundation
import Alamofire

enum CarError {
    case url
    case taskError(error: Error)
    case noResponse
    case noData
    case responseStatusCode(code: Int)
    case invalidJSON
}

enum RESTOperation {
    case save
    case update
    case delete
}

class REST {
    
    private static let basePath = "https://carangas.herokuapp.com/cars"
    
    class func loadBrands(onComplete: @escaping ([Brand]?) -> Void) {
        
        // URL TABELA FIPE

        let urlFipe = "https://fipeapi.appspot.com/api/1/carros/marcas.json"
        guard let url = URL(string: urlFipe) else {
            onComplete(nil)
            return
        }
        AF.request(url).responseJSON {response in
            
            if response.error == nil {
                
                guard let responseFinal = response.response else {
                    onComplete(nil)
                    return
                }
                
                if responseFinal.statusCode == 200 {
                    
                    guard let data = response.data else {
                        onComplete(nil)
                        return
                    }
                    
                    do {
                        let brands = try JSONDecoder().decode([Brand].self, from: data)
                        onComplete(brands)
                    } catch {
                        onComplete(nil)
                    }
                    
                } else {
                    onComplete(nil)
                }
            } else {
                onComplete(nil)
            }
        
        }
    }
    
    class func loadCars(onComplete: @escaping ([Car]) -> Void, onError: @escaping (CarError) -> Void) {
        
        guard let url = URL(string: basePath) else {
            onError(.url)
            return
        }
        
        AF.request(url).responseJSON {response in
            
            if response.error == nil {
                
                guard let responseFinal = response.response else {
                    onError(.noResponse)
                    return
                }
                
                if responseFinal.statusCode == 200 {
                    
                    guard let data = response.data else {
                        onError(.noData)
                        return
                    }
                    
                    do {
                        let cars = try JSONDecoder().decode([Car].self, from: data)
                        onComplete(cars)
                    } catch {
                        onError(.invalidJSON)
                    }
                    
                } else {
                    onError(.responseStatusCode(code: response.response!.statusCode))
                }
            } else {
                onError(.taskError(error: response.error!))
            }
        
        }

    }
    
    class func save(car: Car, onComplete: @escaping (Bool) -> Void, onError: @escaping (CarError) -> Void) {
        applyOperation(car: car, operation: .save, onComplete: onComplete, onError: onError)
    }
    
    class func update(car: Car, onComplete: @escaping (Bool) -> Void, onError: @escaping (CarError) -> Void) {
        applyOperation(car: car, operation: .update, onComplete: onComplete, onError: onError)
    }
    
    class func delete(car: Car, onComplete: @escaping (Bool) -> Void, onError: @escaping (CarError) -> Void) {
        applyOperation(car: car, operation: .delete, onComplete: onComplete, onError: onError)
    }
    
    
    
    private class func applyOperation(car: Car, operation: RESTOperation , onComplete: @escaping (Bool) -> Void, onError: @escaping (CarError) -> Void) {
        
        // o endpoint do servidor para update é: URL/id
        let urlString = basePath + "/" + (car._id ?? "")
        
        guard let url = URL(string: urlString) else {
            onComplete(false)
            return
        }
        var request = URLRequest(url: url)
        var httpMethod: String = ""
        
        switch operation {
        case .delete:
            httpMethod = "DELETE"
        case .save:
            httpMethod = "POST"
        case .update:
            httpMethod = "PUT"
        }
        request.httpMethod = httpMethod
        
        // transformar objeto para um JSON, processo contrario do decoder -> Encoder
        guard let json = try? JSONEncoder().encode(car) else {
            onComplete(false)
            return
        }
        request.httpBody = json
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        AF.request(request)
            .response {response in
                
                if response.error == nil {
                    
                    guard let responseFinal = response.response else {
                        onError(.noResponse)
                        return
                    }
                    
                    if responseFinal.statusCode == 200 {
                        
                        do {
                            onComplete(true)
                        } catch {
                            onError(.invalidJSON)
                        }
                        
                    } else {
                        onError(.responseStatusCode(code: response.response!.statusCode))
                    }
                } else {
                    onError(.taskError(error: response.error!))
                }
            
            }
    }
    
    
} // fim da classe
