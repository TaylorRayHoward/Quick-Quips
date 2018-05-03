//
//  EditTextViewController.swift
//  Quick Quips
//
//  Created by Taylor Howard on 5/29/17.
//  Copyright © 2017 Taylor Howard. All rights reserved.
//

import UIKit

protocol UserEnteredDataDelegate {
    func userEnteredName(data: String, type: String)
}

class EditTextViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet var editTable: UITableView!
    var delegate: UserEnteredDataDelegate? = nil
    var type: String = ""
    var input: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        editTable.delegate = self
        editTable.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = editTable.dequeueReusableCell(withIdentifier: "EditCell", for: indexPath) as! EditCell
        cell.editText.becomeFirstResponder()
        cell.editText.delegate = self
        if input != nil {
            cell.editText.text = input!
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editTable.deselectRow(at: indexPath, animated: false)
        return
    }
    
    @IBAction func saveName(_ sender: UIBarButtonItem) {
        if delegate != nil {
            let indexPath = IndexPath(row: 0, section: 0)
            let cell = editTable.cellForRow(at: indexPath) as! EditCell
            if cell.editText.text != nil {
                let data = cell.editText.text!
                delegate!.userEnteredName(data: data, type: type)
            }
        }
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveName(UIBarButtonItem())
        return true
    }
}
