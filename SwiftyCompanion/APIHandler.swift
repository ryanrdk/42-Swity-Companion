//
//  APIHandler.swift
//  SwiftyCompanion
//
//  Created by Ryan de Kwaadsteniet on 12/4/19.
//  Copyright © 2019 Ryan de Kwaadsteniet. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON

protocol APIDelegate: class {
    func handleRequestError(from: String, err: Error?)
    func handleRequestSuccess(from: String, data: Any)
}

class Api {
    private let CLIENT_ID = "fad8dff51806c2f84c2b2115db315228d2429d8cc1e4c3cb21ece3dd70160d02"
    private let CLIENT_SECRET = "af4f663fcee515abffe4c99e858b9d06b745cfe6efd72485f0a34e18df46c42b"
    private let API_URL = "https://api.intra.42.fr"
    private var token: AccessToken?
    weak var delegate: APIDelegate?
    
    func getAccessToken() {
        // check if the bearer token is still valid, otherwise we will create a new instance.
        if token == nil || token?.is_valid == false {
            let parameters: Parameters = [
                "grant_type": "client_credentials",
                "client_id": CLIENT_ID,
                "client_secret": CLIENT_SECRET
            ]
            
            Alamofire.request(API_URL + "/oauth/token", method: .post, parameters: parameters, encoding: URLEncoding.default).responseSwiftyJSON {
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
                        let primary_token = dataResponse.value!["access_token"].stringValue
                        self.token = AccessToken(access_token: primary_token, expire_date: expire_date)
                        self.delegate?.handleRequestSuccess(from: "getAccessToken", data: true)
                    }
                }
            }
        }
        else {
            self.delegate?.handleRequestSuccess(from: "getAccessToken", data: true)
        }
    }
    
    private func parseUsers(dataResponse: (DataResponse<JSON>)) -> [User] {
        // parse through the JSON data response and create an array of User objects.
        var users: [User] = []
        for (_, elem) in dataResponse.value! {
            users.append(User(login: elem["login"].stringValue, id: Int(elem["id"].doubleValue)))
        }
        return users
    }
    
    private func parseUserProfile(dataResponse: (DataResponse<JSON>)) -> UserProfile {
        // parse through the JSON data response and create a UserProfile object.
        var skills: [Skill] = []
        var projects: [Project] = []
        var login: String = "None"
        var pool: String = "Nowhere"
        var correctionPts: Int = 0
        var level: Float = 0.0
        
        login = dataResponse.value!["login"].stringValue
        pool = dataResponse.value!["pool_year"].stringValue
        correctionPts = Int(dataResponse.value!["correction_point"].doubleValue)
        level = Float(dataResponse.value!["cursus_users"][0]["level"].doubleValue)
        
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
        
        return UserProfile(skills: skills, projects: projects, login: login, pool: pool, correctionPts: correctionPts, level: level,
                           pictureUrl: URL(string: dataResponse.value!["image_url"].stringValue)!, pictureData: nil)
    }
    
    func searchUserLogin(login: String) {
        // fetch a the list of users using an alamofire request
        
        if self.token == nil {
            ///self.delegate?.handleRequestError(from: "searchUserLogin", err: nil)
        }
        else {
            // a dictionary of parameters to apply to a `URLRequest`.
            let parameters: Parameters = [
                "range[login]": "\(login),\(login)z",
                "sort": "login"
            ]
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(self.token!.access_token)"
            ]
            
            Alamofire.request(API_URL + "/v2/users", method: .get, parameters: parameters, headers: headers).responseSwiftyJSON { dataResponse in
                if (dataResponse.error != nil || dataResponse.response?.statusCode != 200) {
                    self.delegate?.handleRequestError(from: "searchUserLogin", err: dataResponse.error)
                }
                else {
                    self.delegate?.handleRequestSuccess(from: "searchUserLogin", data: self.parseUsers(dataResponse: dataResponse))
                }
            }
        }
    }
    
    func getUserProfile(user_id: Int) {
        // fetch a user profile using an alamofire request

        if self.token == nil {
            self.delegate?.handleRequestError(from: "searchUserLogin", err: nil)
        }
        else {
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(self.token!.access_token)"
            ]
            Alamofire.request(API_URL + "/v2/users/\(user_id)", method: .get, headers: headers).responseSwiftyJSON { dataResponse in
                if (dataResponse.error != nil || dataResponse.response?.statusCode != 200) {
                    self.delegate?.handleRequestError(from: "getUserProfile", err: dataResponse.error)
                }
                else {
                    let userprofile = self.parseUserProfile(dataResponse: dataResponse)
                    self.delegate?.handleRequestSuccess(from: "getUserProfile", data: userprofile)
                }
            }
        }
    }
}
