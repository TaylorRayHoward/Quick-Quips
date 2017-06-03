//
// Created by Taylor Howard on 5/29/17.
// Copyright (c) 2017 Taylor Howard. All rights reserved.
//

import UIKit
import RealmSwift
import Toaster

class PictureViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var quips: Results<Object>!
    @IBOutlet var pictureTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        pictureTable.dataSource = self
        pictureTable.delegate = self
        reload()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        pictureTable.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reload()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = pictureTable.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let quip = quips[indexPath.row] as! Quip
        print(quip.text)
        cell.nameLabel.text = quip.name
        cell.categoryLabel.text = quip.category
        let data = getImageFrom(path: quip.text)
        let image = UIImage(data: data!)
        cell.pictureView.image = image!
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quips.count
    }
    
    func reload() {
        quips = DBHelper.sharedInstance.getAll(ofType: Quip.self).filter("type = 'image'")
        self.pictureTable.reloadData()
    }
    
    func getImageFrom(path: String) -> Data? {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let photoURL          = NSURL(fileURLWithPath: documentDirectory)
        let localPath         = photoURL.appendingPathComponent(path)
        let data = FileManager.default.contents(atPath: localPath!.path)
        
        return data
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let quip = quips[indexPath.row] as! Quip
        let data = getImageFrom(path: quip.text)
        let image = UIImage(data: data!)
        UIPasteboard.general.image = image
        pictureTable.deselectRow(at: indexPath, animated: true)
        Toast(text: "Copied!", duration: Delay.short).show()
    }
    
}
