//
//  UserAccountTableViewCell.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/30/22.
//

import UIKit

class UserAccountTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    
    func setMessage(title: String) {
        self.title.text = title
    }
}
