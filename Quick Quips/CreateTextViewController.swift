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
        let quip = Quip(name: getNameText(), type: getCategoryText(), text: getQuipText())
        DBHelper.sharedInstance.writeObject(objects: [quip])
        navigationController?.popViewController(animated: true)
    }
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    func userEnteredName(data: String, type: String) {
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
    
    func getNameText() -> String {
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = actionsTableView.cellForRow(at: indexPath) as! TextCell
        return cell.quipLabel.text!
    }
    
    func getQuipText() -> String {
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = actionsTableView.cellForRow(at: indexPath) as! TextCell
        return cell.quipLabel.text!
    }
    
    func getCategoryText() -> String {
        let indexPath = IndexPath(row: 2, section: 0)
        let cell = actionsTableView.cellForRow(at: indexPath) as! TextCell
        return cell.quipLabel.text!
    }
}
