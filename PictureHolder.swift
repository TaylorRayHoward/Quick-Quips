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
    func populatePictures() -> [String: UIImage] {
        var pics = [String: UIImage]()
        let quips = DBHelper.sharedInstance.getQuips().filter("type = 'image'").sorted(byKeyPath: "frequency", ascending: false)
        for quip in quips {
            let data = getImageDataFrom(path: quip.text)
            let image = UIImage(data: data!)
            pics[quip.id] = image
        }
        return pics
    }
    
    func getImageDataFrom(path: String) -> Data? {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let photoURL = NSURL(fileURLWithPath: documentDirectory)
        let localPath = photoURL.appendingPathComponent(path)
        let data = FileManager.default.contents(atPath: localPath!.path)
        
        return data
    }
    
    func getScaledImageFrom(path: String, for size: CGSize) -> UIImage {
        let image = UIImage(data: getImageDataFrom(path: path)!)!

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
