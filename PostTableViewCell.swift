//
//  PostTableViewCell.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/21/22.
//

import UIKit

protocol PostTableActionDelegate {
    func didDeletePost(rowIndex: Int)
}

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var postedBy: UILabel!
    @IBOutlet weak var postTime: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    private var postTableActionDelegate: PostTableActionDelegate?
    private var rowIndex: Int = 0
    
    public func setMessage(title: String, message: String, postedBy: String, postTime: String, hideDeleteButton: Bool, rowIndex: Int, postTableActionDelegate: PostTableActionDelegate) {
        self.title.text = title
        self.message.text = message
        self.postedBy.text = postedBy
        self.postTime.text = postTime
        self.rowIndex = rowIndex
        self.postTableActionDelegate = postTableActionDelegate
        if hideDeleteButton {
            deleteButton.isHidden = hideDeleteButton
            deleteButton.isUserInteractionEnabled = false
        } else {
            deleteButton.isHidden = false
            deleteButton.isUserInteractionEnabled = true
        }
    }
    
    // Button to delete a given post.
    @IBAction func deletePost(_ sender: Any) {
        self.postTableActionDelegate?.didDeletePost(rowIndex: rowIndex)
    }
    
}
