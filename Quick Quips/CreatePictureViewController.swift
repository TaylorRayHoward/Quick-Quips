//
//  CreatePictureViewController.swift
//  Quick Quips
//
//  Created by Taylor Howard on 6/1/17.
//  Copyright © 2017 Taylor Howard. All rights reserved.
//

import UIKit

class CreatePictureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UserEnteredDataDelegate {

    @IBOutlet weak var pictureView: UIImageView!
    @IBOutlet weak var helpTextLabel: UILabel!
    @IBOutlet weak var actionsTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        pictureView.isUserInteractionEnabled = true
        pictureView.addGestureRecognizer(tapGestureRecognizer)
        actionsTable.dataSource = self
        actionsTable.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        pictureView.image = image
        picker.dismiss(animated: true, completion: nil)
        helpTextLabel.isHidden = true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard  = UIStoryboard(name: "Main", bundle: Bundle.main)
        let cell = actionsTable.cellForRow(at: indexPath) as! TextCell
        let destination = storyboard.instantiateViewController(withIdentifier: "EditTextViewController") as! EditTextViewController
        switch(indexPath.row) {
        case 0:
            destination.type = "name"
        case 1:
            destination.type = "category"
        default:
            destination.type = ""
        }
        destination.delegate = self
        destination.input = cell.quipLabel.text
        navigationController?.pushViewController(destination, animated: true)
        actionsTable.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = actionsTable.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! TextCell
        switch(indexPath.row){
        case 0:
            cell.nameLabel?.text = "Name"
            return cell
        case 1:
            cell.nameLabel?.text = "Category"
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func userEnteredName(data: String, type: String) {
        switch(type){
        case "name":
            let indexPath = IndexPath(row: 0, section: 0)
            let cell = actionsTable.cellForRow(at: indexPath) as! TextCell
            cell.quipLabel.text = data
        case "category":
            let indexPath = IndexPath(row: 1, section: 0)
            let cell = actionsTable.cellForRow(at: indexPath) as! TextCell
            cell.quipLabel.text = data
        default:
            return
        }
    }
    @IBAction func saveButton(_ sender: Any) {
        
    }
    @IBAction func cancelButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    
}
