//
//  CreatePictureViewController.swift
//  Quick Quips
//
//  Created by Taylor Howard on 6/1/17.
//  Copyright © 2017 Taylor Howard. All rights reserved.
//

import UIKit
import Photos
import SwiftGifOrigin

class CreatePictureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UserEnteredDataDelegate {

    var urlForImage: URL? = nil
    var baseUrlForImage: String? = nil
    var assetUrl: URL? = nil
    
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
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let imageUrl          = info[UIImagePickerControllerReferenceURL] as? URL
        let imageName         = UUID().uuidString + (imageUrl?.lastPathComponent ?? "")
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let photoURL          = NSURL(fileURLWithPath: documentDirectory)
        let localPath         = photoURL.appendingPathComponent(imageName)
        
        let data = getDataForPicture(atUrl: imageUrl)
        let gif = UIImage.gif(data: data!)
        pictureView.image = gif
        
        urlForImage = localPath
        assetUrl = imageUrl
        baseUrlForImage = imageName
        picker.dismiss(animated: true, completion: nil)
        helpTextLabel.isHidden = true
    }
    
    func getDataForPicture(atUrl imageUrl: URL?) -> Data? {
        
        let ops = PHImageRequestOptions()
        ops.isSynchronous = true
        
        var returnData: Data? = nil
        
        let asset = PHAsset.fetchAssets(withALAssetURLs: [imageUrl!], options: nil).firstObject!
        PHImageManager.default().requestImageData(for: asset, options: ops, resultHandler: { (imageData, UTI, _, _) in
            if let data = imageData {
                returnData = data
//                try? data.write(to: localPath!)
            }
        })
        return returnData
        
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
        let nameText = getNameText() ?? ""
        let testQuip = DBHelper.sharedInstance.getAll(ofType: Quip.self).filter("name like[c] %@", nameText).first
        
        if urlForImage == nil {
            let alert = UIAlertController(title: "Need picture", message: "Please select a photo", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if nameText == "" {
            let alert = UIAlertController(title: "Missing Fields", message: "You must enter a name to save", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if testQuip != nil {
            let alert = UIAlertController(title: "Non-unique Name", message: "The name must be unique", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let data = getDataForPicture(atUrl: assetUrl)
            if !FileManager.default.fileExists(atPath: urlForImage!.path){
                do {
                    try data!.write(to: urlForImage!)
                    print("file saved")
                }catch {
                    print("error saving file")
                }
            }
            else {
                print("file already exists")
            }
            let quip = Quip(name: getNameText()!, type: "image", text: baseUrlForImage!, category: getCategoryText()!)
            DBHelper.sharedInstance.writeObject(objects: [quip])
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func getNameText() -> String? {
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = actionsTable.cellForRow(at: indexPath) as! TextCell
        return cell.quipLabel.text
    }
    
    func getCategoryText() -> String? {
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = actionsTable.cellForRow(at: indexPath) as! TextCell
        return cell.quipLabel.text
    }

    
}
