//
//  ViewController.swift
//  Quick Quips
//
//  Created by Taylor Howard on 5/29/17.
//  Copyright © 2017 Taylor Howard. All rights reserved.
//

import UIKit
import RealmSwift

class TextViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var quipsTableView: UITableView!
    
    var quips: Results<Object>!
    var filtered: Results<Object>!
    let searchBar = UISearchBar()
    var shouldShowSearchResults = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        quipsTableView.delegate = self
        quipsTableView.dataSource = self
        searchBar.delegate = self
        reload()
        addSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reload()
    }

    func addSearchBar() {
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Search..."
        self.navigationItem.titleView = searchBar
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults { return filtered.count }
        else { return quips.count }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = quipsTableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! TextCell
        let quip: Quip
        if shouldShowSearchResults {
            quip = filtered[indexPath.row] as! Quip
        }
        else {
           quip = quips[indexPath.row] as! Quip
        }
        cell.nameLabel.text = quip.name
        cell.quipLabel.text = quip.text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = quipsTableView.cellForRow(at: indexPath) as! TextCell
        UIPasteboard.general.string = cell.quipLabel.text!
        quipsTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        shouldShowSearchResults = true
        self.quipsTableView.reloadData()
    }
    
    func reload(_ searchText: String? = nil) {
        if shouldShowSearchResults {
            let predicate = NSPredicate(format: "name CONTAINS[c] %@ OR type CONTAINS[c] %@", searchText!, searchText!)
            filtered = DBHelper.sharedInstance.getAll(ofType: Quip.self).filter(predicate)
        }
        else {
            quips = DBHelper.sharedInstance.getAll(ofType: Quip.self)
        }
        
        self.quipsTableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            shouldShowSearchResults = true
            reload(searchText)
        }
        else {
            shouldShowSearchResults = false
            reload()
        }
    }

}

