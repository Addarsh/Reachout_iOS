//
//  ChatRoomTableViewCell.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/21/22.
//

import UIKit

class ChatRoomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var chatRoomName: UILabel!
    @IBOutlet weak var unreadMessagesLabel: UILabel!
    
    public func setName(name: String, numUnreadMessages: Int) {
        self.chatRoomName.text = name
        self.unreadMessagesLabel.text = String(numUnreadMessages)
        if numUnreadMessages == 0 {
            self.unreadMessagesLabel.isHidden = true
        } else {
            self.unreadMessagesLabel.isHidden = false
        }
    }
}
