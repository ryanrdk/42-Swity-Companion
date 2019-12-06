//
//  ProfileViewController.swift
//  SwiftyCompanion
//
//  Created by Ryan de Kwaadsteniet on 12/5/19.
//  Copyright © 2019 Ryan de Kwaadsteniet. All rights reserved.
//

import UIKit
import Alamofire

class ProfileViewController: UIViewController, APIDelegate {
    let projectTableViewDelegate = ProjectTableViewDelegate()
    let skillTableViewDelegate = SkillTableViewDelegate()
    
    var userId: Int?
    
    var userProfile: UserProfile? {
        // set the userProfile information with the information passed
        
        didSet {
            if userProfile != nil {
                projectTableViewDelegate.data = userProfile!.projects
                skillTableViewDelegate.data = userProfile!.skills
                loginLabel?.text = userProfile?.login
                poolLabel?.text = userProfile?.pool
                correctionPtsLabel?.text = "\(userProfile!.correctionPts)"
                levelLabel?.text = userProfile?.getLevelString()
                DispatchQueue.main.async {
                    self.skillTableView?.reloadData()
                    self.projectTableView?.reloadData()
                }
                // as the profile picture can take longer to load, we only call for a response in this view
                Alamofire.request(userProfile!.pictureUrl, method: .get).responseData { response in
                    if response.response?.statusCode == 200 && response.error == nil && response.data != nil {
                        DispatchQueue.main.async {
                            self.profileImageView?.image = UIImage(data: response.data!)
                            self.pictureLoader?.stopAnimating()
                        }
                    }
                    DispatchQueue.main.async {
                        self.pictureLoader?.stopAnimating()
                    }
                }
            }
        }
    }

    @IBOutlet weak var  pictureLoader: UIActivityIndicatorView!
    @IBOutlet weak var  loginLabel: UILabel!
    @IBOutlet weak var  poolLabel: UILabel!
    @IBOutlet weak var  correctionPtsLabel: UILabel!
    @IBOutlet weak var  levelLabel: UILabel!
    @IBOutlet weak var  profileImageView: UIImageView!

    @IBOutlet weak var  skillTableView: UITableView! {
        didSet {
            skillTableView.layer.borderWidth = 1
            skillTableView.layer.cornerRadius = 5.0
            skillTableView.layer.borderColor = UIColor(red: 24/255, green: 200/255, blue: 143/255, alpha: 1.0).cgColor
            skillTableView.delegate = self.skillTableViewDelegate;
            skillTableView.dataSource = self.skillTableViewDelegate;
        }
    }
    
    @IBOutlet weak var  projectTableView: UITableView! {
        didSet {
            projectTableView.layer.borderWidth = 1
            projectTableView.layer.cornerRadius = 5.0
            projectTableView.layer.borderColor = UIColor(red: 24/255, green: 200/255, blue: 143/255, alpha: 1.0).cgColor
            projectTableView.delegate = self.projectTableViewDelegate;
            projectTableView.dataSource = self.projectTableViewDelegate;
        }
    }
    
    private func        roundImageView(imageView: UIImageView) {
        // Just turn rectangular imageView into circle
        imageView.layer.cornerRadius = imageView.frame.size.width / 2;
        imageView.clipsToBounds = true;
    }
    
    func                handleRequestError(from: String, err: Error?) {
        if from == "getUserProfile" {
            self.userId = nil
            self.userProfile = nil
            let alert = UIAlertController(title: "Request Error", message: "From: \(from) Err: Cannot retrieve user profile.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Request Error", message: "From: \(from) Err: \(err)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func                handleRequestSuccess(from: String, data: Any) {
        // When token successfully retrieved. Try to get userProfile.
        if from == "getAccessToken" {
            if userId != nil {
                api.getUserProfile(user_id: userId!)
            }
        }
        if from == "getUserProfile" {
            if data is UserProfile {
                self.userProfile = data as? UserProfile
            }
        }
    }

    override func       viewDidAppear(_ animated: Bool) {
        if userId != nil {
            api.getAccessToken()
        }
    }
    
    override func       viewDidLayoutSubviews() {
        // Round the picture image here to recalculate when screen mode (landscape/portrait) change.
        self.roundImageView(imageView: profileImageView);
    }

    override func       viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func       didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

class SkillTableViewDelegate: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var data: [Skill] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SkillTableViewCell", for: indexPath) as? SkillCustomCell {
            cell.skill = data[indexPath.item]
            return cell;
        }
        return UITableViewCell();
    }
}

class ProjectTableViewDelegate: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var data: [Project] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectTableViewCell", for: indexPath) as? ProjectCustomCell {
            cell.project = data[indexPath.item]
            return cell;
        }
        return UITableViewCell();
    }
}
