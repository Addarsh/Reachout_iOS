//
//  PostTableViewCell.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/21/22.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var message: UILabel!
    
    public func setMessage(message: String) {
        self.message.text = message
    }
    
}
