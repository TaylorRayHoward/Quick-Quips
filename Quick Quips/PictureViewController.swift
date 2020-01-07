//
// Created by Taylor Howard on 5/29/17.
// Copyright (c) 2017 Taylor Howard. All rights reserved.
//

import UIKit
import RealmSwift
import MobileCoreServices
import Toast
import SwiftyGif


class PictureViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    let searchBar = UISearchBar()
    var quips: Results<Object>!
    var filtered: Results<Object>!
    var shouldShowSearchResults = false
    var pictures = NSCache<NSString, UIImage>()
    let gifManager = SwiftyGifManager(memoryLimit:100)
    var debouncedFunc: Debounce<String>!
    
    @IBOutlet var pictureTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pictureTable.dataSource = self
        pictureTable.delegate = self
        searchBar.delegate = self
        quips = DBHelper.sharedInstance.getAll(ofType: Quip.self).filter("type = 'image'").sorted(byKeyPath: "frequency")
        filtered = quips
        addSearchBar()
        pictureTable.tableFooterView = UIView()
        debouncedFunc = debounce(interval: 250, queue: DispatchQueue.main, action: { (identifier: String) in
            self.applySearch(identifier)
        })
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
    
    @objc func cancelSearch() {
        searchBar.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = pictureTable.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.pictureView.clear()
        cell.tag = indexPath.row
        
        let quip: Quip
        
        if shouldShowSearchResults {
            quip = filtered[indexPath.row] as! Quip
        }
        else {
            quip = quips[indexPath.row] as! Quip
        }
        
        if let pic = pictures.object(forKey: quip.id as NSString) {
            
            cell.pictureView.setImage(pic, manager: gifManager)
        }
        else {
            let loader = UIActivityIndicatorView()
            loader.frame = cell.pictureView.frame
            loader.startAnimating()
            loader.center = cell.pictureView.center
            if #available(iOS 12.0, *) {
                if self.traitCollection.userInterfaceStyle == .dark {
                    loader.color = .white
                } else {
                    loader.color = .black
                }
            } else {
                loader.color = .black
            }
            
            cell.pictureView.addSubview(loader)
            
            let text = quip.text
            let scaleFactor = UIScreen.main.scale
            let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            let size = cell.pictureView.bounds.size.applying(scale)
            
            DispatchQueue.global(qos: .userInteractive).async {
                let path = URL(string: text)
                var pic: UIImage
                let isGif = path?.pathExtension.uppercased() == "GIF"
                if isGif {
                    // Some gifs don't render correctly, defense is to just show the
                    do {
                        let data = PictureHolder.sharedInstance.getImageDataFrom(path: text)!
                        pic = try UIImage(gifData: data, levelOfIntegrity: 0.5)
                    } catch {
                        pic = PictureHolder.sharedInstance.getScaledImageFrom(path: text, for: size).fixOrientation()
                    }
                } else {
                    pic = PictureHolder.sharedInstance.getScaledImageFrom(path: text, for: size).fixOrientation()
                }
                DispatchQueue.main.async {
                    // TODO: Find out why caching gifs ruins everything
                    if !isGif {
                        self.pictures.setObject(pic, forKey: quip.id as NSString)
                    }
                    cell.pictureView.setImage(pic, manager: self.gifManager)
                    loader.stopAnimating()
                    loader.removeFromSuperview()
                }
            }
        }
        
        cell.nameLabel.text = quip.name
        cell.categoryLabel.text = quip.category
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
        let data = PictureHolder.sharedInstance.getImageDataFrom(path: quip.text)!
        DispatchQueue.global(qos: .default).async {
            let path = URL(string: quipText)
            if path?.pathExtension.uppercased() == "GIF" {
                UIPasteboard.general.setData(data, forPasteboardType: kUTTypeGIF as String)
            }
            else {
                UIPasteboard.general.image = UIImage(data: data)!.fixOrientation()
            }
            DispatchQueue.main.async {
                self.view.makeToast("Picture successfuly copied")
            }
        }
        DBHelper.sharedInstance.incrementFrequency(for: quip)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        shouldShowSearchResults = true
        reload()
    }
    
    func applySearch(_ searchText: String) {
        if searchText != "" {
            shouldShowSearchResults = true
            reload()
        }
        else {
            shouldShowSearchResults = false
            reload()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        debouncedFunc(searchText)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
