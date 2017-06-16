//
// Created by Taylor Howard on 5/29/17.
// Copyright (c) 2017 Taylor Howard. All rights reserved.
//

import UIKit
import RealmSwift
import Toaster
import SwiftGifOrigin
import MobileCoreServices


class PictureViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    let searchBar = UISearchBar()
    var quips: Results<Object>!
    var filtered: Results<Object>!
    var shouldShowSearchResults = false
    var pictures = [UIImage]()
    
    @IBOutlet var pictureTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pictureTable.dataSource = self
        pictureTable.delegate = self
        searchBar.delegate = self
        quips = DBHelper.sharedInstance.getAll(ofType: Quip.self).filter("type = 'image'").sorted(byKeyPath: "frequency")
        filtered = DBHelper.sharedInstance.getAll(ofType: Quip.self).filter("type = 'image'").sorted(byKeyPath: "frequency")
        reload()
        addSearchBar()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        pictureTable.tableFooterView = UIView()
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = pictureTable.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let quip: Quip
        if shouldShowSearchResults {
            quip = filtered[indexPath.row] as! Quip
        }
        else {
            quip = quips[indexPath.row] as! Quip
        }
        cell.nameLabel.text = quip.name
        cell.categoryLabel.text = quip.category
        cell.pictureView.image = pictures[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults { return filtered.count }
        else { return quips.count }
    }
    
    func reload() {
        if shouldShowSearchResults {
            let predicate = NSPredicate(format: "(name CONTAINS[c] %@ OR category CONTAINS[c] %@) AND type = 'image'", searchBar.text!, searchBar.text!)
            filtered = DBHelper.sharedInstance.getAll(ofType: Quip.self).sorted(byKeyPath: "frequency", ascending: true).filter(predicate)
        }
        pictures = PictureHolder.sharedInstance.populatePictures(forSearch: shouldShowSearchResults, input: searchBar.text)
        sortQuips()
        pictureTable.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pictureTable.deselectRow(at: indexPath, animated: true)
        let quip: Quip
        if shouldShowSearchResults {
            quip = filtered[indexPath.row] as! Quip
        }
        else {
            quip = quips[indexPath.row] as! Quip
        }
        let quipText = quip.text
        DispatchQueue.global(qos: .background).async {
            let data = PictureHolder.sharedInstance.getImageFrom(path: quipText)
            let image = UIImage(data: data!)
            let path = URL(string: quipText)
            if path?.pathExtension.uppercased() == "GIF" {
                UIPasteboard.general.setData(data!, forPasteboardType: kUTTypeGIF as String)
            }
            else {
                UIPasteboard.general.image = image
            }
        }
        DBHelper.sharedInstance.incrementFrequency(for: quip)
        Toast(text: "Copied!", duration: Delay.short).show()
        reload()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        shouldShowSearchResults = true
        reload()
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
            let cell = pictureTable.cellForRow(at: indexPath) as! ImageCell
            let deleteQuip = DBHelper.sharedInstance.getAll(ofType: Quip.self).filter("name = %@ AND type = 'image'", cell.nameLabel.text!).first! as! Quip
            try? FileManager.default.removeItem(at: URL(string: deleteQuip.text)!)
            DBHelper.sharedInstance.deleteObject([deleteQuip])
            reload()
        }
    }
    
    func sortQuips() {
        quips = quips.sorted(byKeyPath: "frequency", ascending: false)
        filtered = filtered.sorted(byKeyPath: "frequency", ascending: false)
    }
    
}
