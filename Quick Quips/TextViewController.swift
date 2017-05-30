//
//  ViewController.swift
//  Quick Quips
//
//  Created by Taylor Howard on 5/29/17.
//  Copyright © 2017 Taylor Howard. All rights reserved.
//

import UIKit
import RealmSwift

class TextViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var quipsTableView: UITableView!
    
    var quips: Results<Object>!

    override func viewDidLoad() {
        super.viewDidLoad()
        quipsTableView.delegate = self
        quipsTableView.dataSource = self
        reload()
        addSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reload()
    }

    func addSearchBar() {
        let searchBar = UISearchBar()
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Search..."
        self.navigationItem.titleView = searchBar
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = quipsTableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! TextCell
        let quip = quips[indexPath.row] as! Quip
        cell.nameLabel.text = quip.name
        cell.quipLabel.text = quip.text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = quipsTableView.cellForRow(at: indexPath) as! TextCell
        UIPasteboard.general.string = cell.quipLabel.text!
        quipsTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func reload() {
        quips = DBHelper.sharedInstance.getAll(ofType: Quip.self)
        self.quipsTableView.reloadData()
    }

}

