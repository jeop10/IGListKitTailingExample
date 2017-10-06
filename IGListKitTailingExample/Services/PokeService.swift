//
//  PokeService.swift
//  IGListKitTailingExample
//
//  Created by Jesus Ortega on 10/5/17.
//  Copyright © 2017 Jesus Ortega. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class PokeService {
    static let instance = PokeService()
    
    var pokemons = [String]()
    var offset = 10;
    
    func callPokeAPI(completion: @escaping CompletionHandler) {
        print("call PokeAPI function")
        print("Cleaning pokemos array")
        pokemons.removeAll()
        print("End of cleaning array")
        
        var body = [String: Any]()
        if offset > 10 {
            body = [
                "offset": offset
            ]
        }
        
        Alamofire.request(POKEMON_API, method: .get, parameters: body, encoding: URLEncoding.queryString).responseString { response in
            if response.result.error == nil {
                print("Request: \(String(describing: response.request))")   // original url request
                print("Response: \(String(describing: response.response))") // http url response
                print("Result: \(response.result)")                         // response serialization result
                
                guard let data = response.data else { return }
                
                
                let json = JSON(data: data)
                let results = json["results"].array
                for item in results! {
                    let name = item["name"].stringValue
                    if name != "" {
                        self.pokemons.append(name)
                    }
                }
                self.offset += 10
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
