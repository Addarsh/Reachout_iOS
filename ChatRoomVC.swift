//
//  ChatRoomVC.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/21/22.
//

import UIKit

class ChatRoomVC: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var roomName: UILabel!
    
    var chatRoomName: String = ""
    
    var messagesInRoom: [ChatMessage] = [ChatMessage(text: "Monkey", sent_by_me: false), ChatMessage(text: "Donkey", sent_by_me: false), ChatMessage(text: "Goat", sent_by_me: true), ChatMessage(text: "Hippo", sent_by_me: false)]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textField.layer.borderWidth = 1
        
        roomName.text = chatRoomName
        
        // call the 'keyboardWillShow' function when the view controller receive notification that keyboard is going to be shown
        NotificationCenter.default.addObserver(self, selector: #selector(ChatRoomVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // call the 'keyboardWillHide' function when the view controlelr receive notification that keyboard is going to be hidden
        NotificationCenter.default.addObserver(self, selector: #selector(ChatRoomVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.hideKeyboardWhenTappedAround()
        
        
        // Table view setup.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.white
    }
    
    // Based on code from https://fluffy.es/move-view-when-keyboard-is-shown/
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
           // if keyboard size is not available for some reason, dont do anything
           return
        }
      
      // move the root view up by the distance of keyboard height
      self.view.frame.origin.y = 0 - keyboardSize.height
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
      // move back the root view origin to zero
      self.view.frame.origin.y = 0
    }
    
    
    // Handler for when user posts a message.
    @IBAction func didSendMessage(_ sender: Any) {
        guard let message = textField.text else {
            return
        }
        
        // Add to messages in room.
        messagesInRoom.append(ChatMessage(text: message,sent_by_me: true))
        self.tableView.reloadData()
        
        // Clear text field.
        self.textField.text = ""
    }

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}

extension ChatRoomVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesInRoom.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = self.messagesInRoom[indexPath.row]
        
        if !message.sent_by_me {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OtherMessageTableViewCell") as! OtherMessageTableViewCell
            cell.setMessage(message: message.text)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessageTableViewCell") as! MyMessageTableViewCell
        cell.setMessage(message: message.text)
        return cell
    }
    
}

// Put this piece of code anywhere you like
extension ChatRoomVC {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(ChatRoomVC.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
