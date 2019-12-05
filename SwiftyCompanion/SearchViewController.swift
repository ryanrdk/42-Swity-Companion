//
//  ViewController.swift
//  SwiftyCompanion
//
//  Created by Ryan de Kwaadsteniet on 12/2/19.
//  Copyright © 2019 Ryan de Kwaadsteniet. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, APIDelegate {

    var searchActive : Bool = false
    let searchTableViewDelegate = SearchTableViewDelegate()
    let loginCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-")
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.enablesReturnKeyAutomatically = false
            searchBar.delegate = self;
        }
    }
    
    @IBOutlet weak var searchTableView: UITableView! {
        didSet {
            searchTableView.delegate = searchTableViewDelegate;
            searchTableView.dataSource = searchTableViewDelegate;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        api.delegate = self
    }

    func handleRequestError(from: String, err: Error?) {
        if from == "searchUserLogin" {
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
            }
        }
        let alert = UIAlertController(title: "Request Error", message: "From: \(from) Err: \(String(describing: err))", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleRequestSuccess(from: String, data: Any) {
        if from == "searchUserLogin" {
            if let users = data as? [User] {
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.searchTableViewDelegate.data = users
                    self.searchTableViewDelegate.filtered = users
                    self.searchTableView.reloadData()
                }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Filter searched elements in cache if exist, else, perform a request to get elements.

        // If searchText contain only valid login characters
        if searchText.rangeOfCharacter(from: self.loginCharacterSet.inverted) == nil {
            // If size is > 2 (to avoid too many requests) and < 10 (max len of login + 1)
            if searchText.count >= 2  && searchText.count < 10 {
                let data = searchTableViewDelegate.data;
                
                // Filter data based on already retrieved data
                searchTableViewDelegate.filtered = data.filter({ (user) -> Bool in
                    let tmp: String = user.login.lowercased()
                    return (tmp.hasPrefix(searchText.lowercased()))
                })
                
                // Else retrieve data from API
                if(searchTableViewDelegate.filtered.count == 0){
                    searchActive = false;
                    self.loadingIndicator.startAnimating()
                    api.getAccessToken()
                    api.searchUserLogin(login: searchText.lowercased())
                }
                else {
                    searchActive = true;
                }
                self.searchTableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userProfileSegue" {
            // This segue is trigger if user click on a result into researchTableView
            // So we hydrate our next viewController with the selected userId, allowing the next page to retrieve UserInformations.
            
            let vc = segue.destination as! ProfileViewController
            api.delegate = vc
            
            if sender != nil && sender is UITableViewCell {
                let index = searchTableView.indexPathForSelectedRow!
                vc.userId = searchTableViewDelegate.filtered[index.item].id
            }
            else {
                vc.userId = searchTableViewDelegate.filtered[0].id
            }
        }
    }
    
}

class SearchTableViewDelegate: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var data: [User] = []
    var filtered: [User] = []
    
    func tableView(_ tableoView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        cell.textLabel?.text = filtered[indexPath.item].login
        return cell;
    }
}
