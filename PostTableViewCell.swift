//
//  PostTableViewCell.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/21/22.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var postedBy: UILabel!
    @IBOutlet weak var postTime: UILabel!
    
    public func setMessage(title: String, message: String, postedBy: String, postTime: String) {
        self.title.text = title
        self.message.text = message
        self.postedBy.text = postedBy
        self.postTime.text = postTime
    }
    
}
