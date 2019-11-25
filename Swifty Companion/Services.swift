//
//  Services.swift
//  42Events
//
//  Created by Harmun Rossouw on 2019/10/12.
//  Copyright © 2019 Rush00Team. All rights reserved.
//

import Foundation
import UIKit

class Client {
    //variables
    var userFirstName : String = ""
    var userLastName: String = ""
    var userLogin: String = ""
    var userPhoto: String = ""
    var userLevel: Double = 0
    //var curses: String = ""
    var cursusNames: [String] = []
    var cursusLevels: [Double] = []
    var events: [EventData] = []
    
    var campuses: [CampusData] = []
    
    var cursuses: [CursusData] = []
    
    //GET gets user info (firstName, lastName, login, photo) and returns as string
    func getUserInfo(token: String,username: String,  completion: @escaping (_ firstName: String, _ lastName: String, _ login: String, _ photo:String, _ userLevel:Double, _ cursusName:[String], _ cursusLevel:[Double]) -> ()) {
        //setup URL and headers
        let url = URL(string:"https://api.intra.42.fr/v2/users/\(username)/")!
        let headers = [ "Authorization": "Bearer \(token)"]
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        //make request task
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                print("error: \(error)")
            } else {
                if let response = response as? HTTPURLResponse {
                    print("statusCode: \(response.statusCode)")
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    do {
                        let jData = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                        if jData["cursus_users"] != nil {
                            let cursesList: [NSDictionary] = (jData["cursus_users"] as? [NSDictionary])!
                            self.userFirstName = jData["first_name"] as? String ?? ""
                            self.userLastName = jData["last_name"] as? String ?? ""
                            self.userLogin = jData["login"] as? String ?? ""
                            self.userPhoto = jData["image_url"] as? String ?? ""
                            
                            for elem in cursesList {
                                //let name = elem["cursus_users"] as! NSDictionary
                                //print(name)
                                self.userLevel = elem["level"] as? Double ?? 0
                                let skillsList: [NSDictionary] = (elem["skills"] as? [NSDictionary])!
                                for elem in skillsList{
                                    let skillName = elem["name"]
                                    let skillLevel = elem["level"]
                                    self.cursusNames.append(skillName as? String ?? "")
                                    self.cursusLevels.append(skillLevel as? Double ?? 0)
                                }
                                
                            }
                            //                        print(self.cursusNames, self.cursusLevels)
                            completion(self.userFirstName, self.userLastName, self.userLogin, self.userPhoto,self.userLevel, self.cursusNames, self.cursusLevels)
                        }
                    } catch let er {
                        print(er)
                    }
                    
                }
            }
        }
        task.resume()
    }
    
    //GET JSON events object
    func getEventsInfo(token: String, completion: @escaping (_ events: [EventData]) -> ()) {
        //setup URL and headers
        let url = URL(string:"https://api.intra.42.fr/v2/events?&filter[future]=true")!
        let headers = [ "Authorization": "Bearer \(token)"]
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        //make request task
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                print("error: \(error)")
            } else {
                if let response = response as? HTTPURLResponse {
                    print("statusCode: \(response.statusCode)")
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    do {
                        let jData = try JSONSerialization.jsonObject(with: data, options: []) as! [NSDictionary]
                        //print(jData)
                        for elem in jData {
                            //                            print(elem["id"])
                            self.events.append(EventData(event: elem as! [String : Any]))
                        }
                        //print(self.events)
                        completion(self.events)
                    }
                    catch let er {
                        print(er)
                    }
                }
            }
        }
        task.resume()
    }
    
    func getCampusInfo(token: String, completion: @escaping (_ campuses : [CampusData]) -> ()) {
        //setup URL and headers
        let url = URL(string:"https://api.intra.42.fr/v2/campus")!
        let headers = [ "Authorization": "Bearer \(token)"]
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        //make request task
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                print("error: \(error)")
            } else {
                if let response = response as? HTTPURLResponse {
                    print("statusCode: \(response.statusCode)")
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    do {
                        let jData = try JSONSerialization.jsonObject(with: data, options: []) as! [NSDictionary]
                        //print(jData)
                        for elem in jData {
                            //                            print(elem["id"])
                            self.campuses.append(CampusData(event: elem as! [String : Any]))
                        }
                        //print(self.events)
                        completion(self.campuses)
                    }
                    catch let er {
                        print(er)
                    }
                }
            }
        }
        task.resume()
    }
    
    func getCursusInfo(token: String, completion: @escaping (_ cursuses: [CursusData]) -> ()) {
        //setup URL and headers
        let url = URL(string:"https://api.intra.42.fr/v2/cursus")!
        let headers = [ "Authorization": "Bearer \(token)"]
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        //make request task
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                print("error: \(error)")
            } else {
                if let response = response as? HTTPURLResponse {
                    print("statusCode: \(response.statusCode)")
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    do {
                        let jData = try JSONSerialization.jsonObject(with: data, options: []) as! [NSDictionary]
                        //print(jData)
                        for elem in jData {
                            //                            print(elem["id"])
                            self.cursuses.append(CursusData(event: elem as! [String : Any]))
                        }
                        //print(self.cursuses)
                        completion(self.cursuses)
                    }
                    catch let er {
                        print(er)
                    }
                }
            }
        }
        task.resume()
    }
}
