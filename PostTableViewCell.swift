//
//  PostTableViewCell.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/21/22.
//

import UIKit

protocol PostTableActionDelegate {
    func didDeletePost(rowIndex: Int)
    func didStartChat(rowIndex: Int)
}

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var postedBy: UILabel!
    @IBOutlet weak var postTime: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    private var postTableActionDelegate: PostTableActionDelegate?
    private var rowIndex: Int = 0
    
    public func setMessage(title: String, message: String, postedBy: String, postTime: String, hideDeleteButton: Bool, hideChatButton: Bool, rowIndex: Int, postTableActionDelegate: PostTableActionDelegate) {
        self.title.text = title
        self.message.text = message
        self.postedBy.text = postedBy
        self.postTime.text = postTime
        self.rowIndex = rowIndex
        self.postTableActionDelegate = postTableActionDelegate

        self.deleteButton.isHidden = hideDeleteButton
        self.deleteButton.isUserInteractionEnabled = !hideDeleteButton
        
        self.chatButton.isHidden = hideChatButton
        self.chatButton.isUserInteractionEnabled = !hideChatButton
    }
    
    // Button to delete a given post.
    @IBAction func deletePost(_ sender: Any) {
        self.postTableActionDelegate?.didDeletePost(rowIndex: rowIndex)
    }
    
    @IBAction func startChat(_ sender: Any) {
        self.postTableActionDelegate?.didStartChat(rowIndex: rowIndex)
    }
    
}
