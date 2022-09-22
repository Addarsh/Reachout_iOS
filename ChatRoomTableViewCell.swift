//
//  ChatRoomTableViewCell.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/21/22.
//

import UIKit

class ChatRoomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var chatRoomName: UILabel!
    
    public func setName(name: String) {
        self.chatRoomName.text = name
    }
}
