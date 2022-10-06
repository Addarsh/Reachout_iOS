//
//  MyMessageTableViewCell.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/22/22.
//

import UIKit

class MyMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var message: UILabel!
    
    func setMessage(message: String) {
        self.message.text = message
    }

}
