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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        api.delegate = self
        ///api.getAccessToken()
    }

    func handleRequestError(from: String, err: Error?) {
        if from == "searchUserLogin" {
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
            }
        }
        let alert = UIAlertController(title: "Request Error", message: "From: \(from) Err: Response bucket too large.", preferredStyle: .alert)
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
        // filter the current data, otherwise retrieve from API call

        // validation condition for checking if the search text uses the correct characters
        if searchText.rangeOfCharacter(from: self.loginCharacterSet.inverted) == nil {
            // to avoid too many requests set the minimum value to 2 and maximum amount in a username is 10
            if searchText.count >= 2  && searchText.count < 10 {
                let data = searchTableViewDelegate.data;
                
                // filter based on search text
                searchTableViewDelegate.filtered = data.filter({ (user) -> Bool in
                    let tmp: String = user.login.lowercased()
                    return (tmp.hasPrefix(searchText.lowercased()))
                })
                
                // make an API call if the filter count is 0
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
            // on click on one of the cells (usernames), we will perform a segue
            // we will hydrate our next view with the corresponding user profile data
            
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
