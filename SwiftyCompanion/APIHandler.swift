//
//  APIHandler.swift
//  SwiftyCompanion
//
//  Created by Ryan de Kwaadsteniet on 12/4/19.
//  Copyright © 2019 Ryan de Kwaadsteniet. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON

protocol APIDelegate: class {
    func handleRequestError(from: String, err: Error?)
    func handleRequestSuccess(from: String, data: Any)
}

class Api {
    private let APP_ID = "fad8dff51806c2f84c2b2115db315228d2429d8cc1e4c3cb21ece3dd70160d02"
    private let APP_SECRET = "af4f663fcee515abffe4c99e858b9d06b745cfe6efd72485f0a34e18df46c42b"
    private let APP_REDIRECT_URI = "Swifty://Swifty"
    private let api_url = "https://api.intra.42.fr"
    private var token: AccessToken?
    weak var delegate: APIDelegate?
    
    private func getUsersFromResponse(dataResponse: (DataResponse<JSON>)) -> [User]{
        // Handle JSON API data and turn it into an Array of User object.
        var users: [User] = []
        for (_, elem) in dataResponse.value! {
            users.append(User(login: elem["login"].stringValue, id: Int(elem["id"].doubleValue)))
        }
        return users
    }
    
    private func getUserProfileFromResponse(dataResponse: (DataResponse<JSON>)) -> UserProfile {
        // Handle JSON API data and turn it into an UserProfile object.
        var skills: [Skill] = []
        var projects: [Project] = []
        var achievements: [Achievement] = []
        var login: String = "None"
        var grade: String = "None"
        var wallet: Int = 0
        var correctionPts: Int = 0
        var position: String = "None"
        var level: Float = 0.0
        
        login = dataResponse.value!["login"].stringValue
        wallet = Int(dataResponse.value!["wallet"].doubleValue)
        correctionPts = Int(dataResponse.value!["correction_point"].doubleValue)
        position = dataResponse.value!["location"].stringValue
        level = Float(dataResponse.value!["cursus_users"][0]["level"].doubleValue)
        grade = dataResponse.value!["cursus_users"][0]["grade"].stringValue
        
        for (_, skill) in dataResponse.value!["cursus_users"][0]["skills"] {
            skills.append(Skill(name: skill["name"].stringValue, score: Float(skill["level"].doubleValue)))
        }
        
        for (_, project) in dataResponse.value!["projects_users"] {
            
            projects.append(Project(
                name: project["project"]["name"].stringValue,
                score: Float(project["final_mark"].doubleValue),
                validated: Bool(truncating: project["validated?"].doubleValue as NSNumber),
                status: project["status"].stringValue)
            )
        }
        
        for (_, achievement) in dataResponse.value!["achievements"] {
            achievements.append(Achievement(
                name: achievement["name"].stringValue,
                description: achievement["description"].stringValue,
                imageUrl: URL(string: achievement["image"].stringValue)!,
                svgData: nil)
            )
        }
        
        return UserProfile(skills: skills, projects: projects, achievements: achievements, login: login,
                           grade: grade, wallet: wallet, correctionPts: correctionPts, position: position, level: level,
                           pictureUrl: URL(string: dataResponse.value!["image_url"].stringValue)!, pictureData: nil)
    }
    
    func getAccessToken() {
        // Check if an valid token is already in cache. Else ask a new token to the API.
        if token == nil || token?.is_valid == false {
            let parameters: Parameters = [
                "grant_type": "client_credentials",
                "client_id": APP_ID,
                "client_secret": APP_SECRET
            ]
            
            Alamofire.request(api_url + "/oauth/token", method: .post, parameters: parameters, encoding: URLEncoding.default).responseSwiftyJSON {
                dataResponse in
                if (dataResponse.error != nil || dataResponse.response?.statusCode != 200) {
                    self.delegate?.handleRequestError(from: "getAccessToken", err: dataResponse.error)
                }
                else {
                    if dataResponse.value?["expires_in"] != nil &&
                        dataResponse.value?["created_at"] != nil &&
                        dataResponse.value?["access_token"] != nil {
                        let expire_date = Date(timeIntervalSince1970: (
                            dataResponse.value!["expires_in"].doubleValue) + (dataResponse.value!["created_at"].doubleValue
                        ))
                        let access_token = dataResponse.value!["access_token"].stringValue
                        self.token = AccessToken(access_token: access_token, expire_date: expire_date)
                        self.delegate?.handleRequestSuccess(from: "getAccessToken", data: true)
                    }
                }
            }
        }
        else {
            self.delegate?.handleRequestSuccess(from: "getAccessToken", data: true)
        }
    }
    
    func searchUserLogin(login: String) {
        // Search all users with login starting with 'login'

        if self.token == nil {
            //self.delegate?.handleRequestError(from: "searchUserLogin", err: nil)
        }
        else {
            let parameters: Parameters = [
                "range[login]": "\(login),\(login)z",  // A little bit tricky but only way to filter user login the way we want with API.
                "sort": "login"
            ]
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(self.token!.access_token)"
            ]
            
            Alamofire.request(api_url + "/v2/users", method: .get, parameters: parameters, headers: headers).responseSwiftyJSON { dataResponse in
                if (dataResponse.error != nil || dataResponse.response?.statusCode != 200) {
                    self.delegate?.handleRequestError(from: "searchUserLogin", err: dataResponse.error)
                }
                else {
                    self.delegate?.handleRequestSuccess(from: "searchUserLogin", data: self.getUsersFromResponse(dataResponse: dataResponse))
                }
            }
        }
    }
    
    func getUserProfile(user_id: Int) {
        // Retrieve from API the UserProfile matching with the user_id

        if self.token == nil {
            self.delegate?.handleRequestError(from: "searchUserLogin", err: nil)
        }
        else {
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(self.token!.access_token)"
            ]
            Alamofire.request(api_url + "/v2/users/\(user_id)", method: .get, headers: headers).responseSwiftyJSON { dataResponse in
                if (dataResponse.error != nil || dataResponse.response?.statusCode != 200) {
                    self.delegate?.handleRequestError(from: "getUserProfile", err: dataResponse.error)
                }
                else {
                    let userprofile = self.getUserProfileFromResponse(dataResponse: dataResponse)
                    self.delegate?.handleRequestSuccess(from: "getUserProfile", data: userprofile)
                }
            }
        }
    }
}
