//
//  ViewController.swift
//  Quick Quips
//
//  Created by Taylor Howard on 5/29/17.
//  Copyright © 2017 Taylor Howard. All rights reserved.
//

import UIKit
import RealmSwift
import Toaster

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
        quipsTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reload()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchBar.endEditing(true)
    }

    func addSearchBar() {
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Search..."
        self.navigationItem.titleView = searchBar
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cancelSearch))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func cancelSearch() {
        searchBar.endEditing(true)
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
        cell.categoryLabel.text = quip.category
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = quipsTableView.cellForRow(at: indexPath) as! TextCell
        UIPasteboard.general.string = cell.quipLabel.text!
        quipsTableView.deselectRow(at: indexPath, animated: true)
        Toast(text: "Copied!", duration: Delay.short).show()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        shouldShowSearchResults = true
        self.quipsTableView.reloadData()
    }
    
    func reload() {
        if shouldShowSearchResults {
            let predicate = NSPredicate(format: "name CONTAINS[c] %@ OR category CONTAINS[c] %@ AND type = 'text'", searchBar.text!, searchBar.text!)
            filtered = DBHelper.sharedInstance.getAll(ofType: Quip.self).filter(predicate)
        }
        else {
            quips = DBHelper.sharedInstance.getAll(ofType: Quip.self).filter("type = 'text'")
        }
        
        self.quipsTableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            shouldShowSearchResults = true
            reload()
        }
        else {
            shouldShowSearchResults = false
            reload()
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cell = tableView.cellForRow(at: indexPath) as! TextCell
            let deleteQuip = DBHelper.sharedInstance.getAll(ofType: Quip.self).filter("name = %@ AND type = 'text'", cell.nameLabel.text!).first!
            DBHelper.sharedInstance.deleteObject([deleteQuip])
            reload()
        }
    }

}

