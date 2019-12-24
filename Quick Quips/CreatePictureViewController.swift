//
//  CreatePictureViewController.swift
//  Quick Quips
//
//  Created by Taylor Howard on 6/1/17.
//  Copyright © 2017 Taylor Howard. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
import SwiftyGif

class CreatePictureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UserEnteredDataDelegate {
    
    var urlForImage: URL? = nil
    var baseUrlForImage: String? = nil
    var assetUrl: URL? = nil
    var action: saveType? = nil
    var clipboardData: Data? = nil
    
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
    
    func createDeniedAlert() -> UIAlertController {
        let alert = UIAlertController(title: "You have denied picture permission", message: "You must allow this from settings", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: {
            _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }))
        return alert;
    }
    
    func createUIImagePicker() -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        return imagePickerController;
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let imageAction = UIAlertAction(title: "Photos", style: .default) { action in
            let permission = PHPhotoLibrary.authorizationStatus();
            switch(permission) {
            case .denied, .restricted:
                let alert = self.createDeniedAlert()
                self.present(alert, animated: true, completion: nil)
            case .authorized:
                let controller = self.createUIImagePicker()
                self.present(controller, animated: true, completion: nil)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({status in
                    if status == .authorized {
                        let controller = self.createUIImagePicker()
                        self.present(controller, animated: true, completion: nil)
                    } else {
                        let alert = self.createDeniedAlert()
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
        
        let clipboardAction = UIAlertAction(title: "Clipboard", style: .default) { action in
            let gif = UIPasteboard.general.data(forPasteboardType: kUTTypeGIF as String)
            if gif == nil {
                let image = UIPasteboard.general.image
                if let i = image {
                    self.urlForImage = URL(string: "asset.png")
                    self.clipboardData = image!.pngData()
                    self.helpTextLabel.isHidden = true
                    self.pictureView.image = i
                }
                else {
                    return
                }
            }
            else {
                self.clipboardData = gif!
                self.urlForImage = URL(string: "asset.gif")
                self.helpTextLabel.isHidden = true
                let image = try! UIImage(gifData: gif!)
                self.pictureView.setGifImage(image)
            }
            self.action = .clipboard
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        actionSheet.addAction(imageAction)
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(clipboardAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        let imageUrl = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.referenceURL)] as? URL
        let imageName = UUID().uuidString + (imageUrl?.lastPathComponent ?? "")
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let photoURL = NSURL(fileURLWithPath: documentDirectory)
        let localPath = photoURL.appendingPathComponent(imageName)
        let ext = localPath?.pathExtension
        let data = getDataForPicture(atUrl: imageUrl)

        var pic: UIImage?
        
        if ext?.lowercased() == "gif" {
            pic = try! UIImage(gifData: data!)
        } else {
            pic = UIImage(data: data!)
        }
        
        if pic == nil {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        pictureView.image = pic
        urlForImage = localPath
        assetUrl = imageUrl
        baseUrlForImage = imageName
        helpTextLabel.isHidden = true
        action = saveType.photos
        picker.dismiss(animated: true, completion: nil)
    }
    
    func getDataForPicture(atUrl imageUrl: URL?) -> Data? {
        
        let ops = PHImageRequestOptions()
        ops.isSynchronous = true
        
        var returnData: Data? = nil
        let asset = PHAsset.fetchAssets(withALAssetURLs: [imageUrl!], options: nil).firstObject!
        PHImageManager.default().requestImageData(for: asset, options: ops, resultHandler: { (imageData, UTI, _, _) in
            if let data = imageData {
                returnData = data
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
        
        if !hasCompletedPhoto() {
            let alert = UIAlertController(title: "Need picture", message: "Please select a photo", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if nameText == "" {
            let alert = UIAlertController(title: "Missing Fields", message: "You must enter a name to save", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if testQuip != nil {
            let alert = UIAlertController(title: "Non-unique Name", message: "The name must be unique", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            switch(action!) {
            case .photos:
                saveFromPhotos()
            case .clipboard:
                saveFromClipboard()
            default:
                return
            }
            
            navigationController?.popViewController(animated: true)
        }
    }
    
    func saveFromPhotos() {
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
    }
    
    func saveFromClipboard() {
        let imageName         = UUID().uuidString + (urlForImage?.absoluteString ?? "")
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let photoURL          = NSURL(fileURLWithPath: documentDirectory)
        let localPath  = photoURL.appendingPathComponent(imageName)
        
        baseUrlForImage = imageName
        urlForImage = localPath
        
        if !FileManager.default.fileExists(atPath: urlForImage!.path){
            do {
                try clipboardData!.write(to: urlForImage!)
                print("file saved")
            } catch {
                print("error saving file")
            }
        }
        else {
            print("file already exists")
        }
        let quip = Quip(name: getNameText()!, type: "image", text: baseUrlForImage!, category: getCategoryText()!)
        DBHelper.sharedInstance.writeObject(objects: [quip])
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
    
    func hasCompletedPhoto() -> Bool {
        return assetUrl != nil || clipboardData != nil
    }
    
}

enum saveType {
    case photos
    case clipboard
    case url
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
