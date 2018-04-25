//
// Created by Taylor Howard on 5/29/17.
// Copyright (c) 2017 Taylor Howard. All rights reserved.
//

import UIKit

class CreateTextViewController: UITableViewController, UserEnteredDataDelegate {
    @IBOutlet var actionsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        actionsTableView.delegate = self
        actionsTableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = actionsTableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! TextCell
        switch(indexPath.row){
        case 0:
            cell.nameLabel?.text = "Name"
            return cell
        case 1:
            cell.nameLabel?.text = "Text"
            return cell
        case 2:
            cell.nameLabel?.text = "Category"
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard  = UIStoryboard(name: "Main", bundle: Bundle.main)
        let cell = actionsTableView.cellForRow(at: indexPath) as! TextCell
        let destination = storyboard.instantiateViewController(withIdentifier: "EditTextViewController") as! EditTextViewController
        switch(indexPath.row) {
        case 0:
            destination.type = "name"
        case 1:
            destination.type = "quip"
        case 2:
            destination.type = "category"
        default:
            destination.type = ""
        }
        destination.delegate = self
        destination.input = cell.quipLabel.text
        navigationController?.pushViewController(destination, animated: true)
        actionsTableView.deselectRow(at: indexPath, animated: true)
    }

    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        let nameText = getNameText()
        let quipText = getQuipText()
        let testQuip = DBHelper.sharedInstance.getAll(ofType: Quip.self).filter("name like[c] %@", nameText ?? "").first
        if testQuip != nil {
            let alert = UIAlertController(title: "Non-unique Name", message: "The name must be unique", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if let name = nameText, let quip = quipText, name != "", quip != "" {
            let quip = Quip(name: name, type: "text", text: quip, category: getCategoryText() ?? "")
            DBHelper.sharedInstance.writeObject(objects: [quip])
            navigationController?.popViewController(animated: true)
        }
        else {
            let alert = UIAlertController(title: "Missing Fields", message: "You must enter a name and text to save", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func userEnteredName(data: String, type: String) {
        switch(type){
        case "name":
            let indexPath = IndexPath(row: 0, section: 0)
            let cell = actionsTableView.cellForRow(at: indexPath) as! TextCell
            cell.quipLabel.text = data
        case "quip":
            let indexPath = IndexPath(row: 1, section: 0)
            let cell = actionsTableView.cellForRow(at: indexPath) as! TextCell
            cell.quipLabel.text = data
        case "category":
            let indexPath = IndexPath(row: 2, section: 0)
            let cell = actionsTableView.cellForRow(at: indexPath) as! TextCell
            cell.quipLabel.text = data
        default:
            return
        }
    }
    
    @objc func getNameText() -> String? {
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = actionsTableView.cellForRow(at: indexPath) as! TextCell
        return cell.quipLabel.text
    }
    
    @objc func getQuipText() -> String? {
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = actionsTableView.cellForRow(at: indexPath) as! TextCell
        return cell.quipLabel.text
    }
    
    @objc func getCategoryText() -> String? {
        let indexPath = IndexPath(row: 2, section: 0)
        let cell = actionsTableView.cellForRow(at: indexPath) as! TextCell
        return cell.quipLabel.text
    }
}
