//
//  APIConnection.swift
//  42Events
//
//  Created by abduraghmaan GABRIELS on 2019/10/13.
//  Copyright © 2019 Rush00Team. All rights reserved.
//

import Foundation

enum crededntials : String {
    //your application's intra id & secret key
    case client_id = "723fed767a337f28015b7b0c14aa2040ee9aa4503561fff7d188c124b9d9817c"
    case client_secret = "2a27cdd1948dabbe45607def1b684d0230e120bea1c854ba0078e2c87cc9af4c"
}

class APIConnection{
    var token:String!=""
    func genTok(completion: @escaping (_ token: String) -> ()){
        //setup URL and headers
        let url = URL(string: "https://api.intra.42.fr/oauth/token?client_id=\(crededntials.client_id.rawValue)&client_secret=\(crededntials.client_secret.rawValue)&grant_type=client_credentials")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        //make request task
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("error: \(error)")
            } else {
                if let response = response as? HTTPURLResponse {
                    print("statusCode: \(response.statusCode)")
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    //print("data: \(dataString)")
                    let jData = try? JSONSerialization.jsonObject(with: data, options: [])
                    if let jData = jData as? [String: Any] {
                        //print(jData)
                        self.token = jData["access_token"] as! String
                        //                                print("Self: \(self.token)")
                        completion(self.token)
                    }
                }
            }
        }
        task.resume()
        print("Task resumed, getting Token")
        //        return token;
    }
    func getToken()->String{
        return token
    }
}
