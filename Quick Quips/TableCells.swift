//
//  TableCells.swift
//  Quick Quips
//
//  Created by Taylor Howard on 5/29/17.
//  Copyright © 2017 Taylor Howard. All rights reserved.
//

import UIKit

class TextCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quipLabel: UILabel!
}

class EditCell: UITableViewCell {
    @IBOutlet weak var editText: UITextField!
}
