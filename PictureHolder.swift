//
//  PicturesSingleton.swift
//  Quick Quips
//
//  Created by Taylor Howard on 6/11/17.
//  Copyright © 2017 Taylor Howard. All rights reserved.
//

import UIKit

class PictureHolder {
    private init() { }
    
    static var sharedInstance: PictureHolder {
        let instance = PictureHolder()
        return instance
    }
    func populatePictures() -> [UIImage] {
        var pics = [UIImage]()
        let quips = DBHelper.sharedInstance.getQuips().sorted(byKeyPath: "frequency", ascending: false)
        for quip in quips {
            let data = getImageFrom(path: quip.text)
            let image = UIImage(data: data!)
            pics.append(image!)
        }
        return pics
        
    }
    
    func getImageFrom(path: String) -> Data? {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let photoURL = NSURL(fileURLWithPath: documentDirectory)
        let localPath = photoURL.appendingPathComponent(path)
        let data = FileManager.default.contents(atPath: localPath!.path)
        
        return data
    }
}
