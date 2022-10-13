//
//  ChatRoomVC.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/21/22.
//

import UIKit

class ChatRoomVC: UIViewController {
    
    @IBOutlet weak var loadingView: UIView! {
        didSet {
            loadingView.layer.cornerRadius = 6
            loadingView.isHidden = true
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var roomName: UILabel!
    
    @IBOutlet weak var acceptInvite: UIButton!
    
    @IBOutlet weak var postMessageView: UITextView!
    
    @IBOutlet weak var rejectInvite: UIButton!
    
    @IBOutlet weak var acceptOrRejectStackView: UIStackView!
    
    @IBOutlet weak var inviteMessageLabel: UILabel!
    
    private var chatRoomTimer: Timer?
    
    // Poll every 5 seconds when the app is active.
    private let chatRoomIntervalSeconds: Double = 5
    
    private var myUserId: String = ""
    
    private var chatRoom: ChatService.ChatRoom!
    
    private var authToken: String = ""
    
    var messagesInRoom: [ChatService.ChatMessage] = []
    
    private let chatServiceQueue = DispatchQueue(label: "Chat service queue", qos: .default, attributes: [], autoreleaseFrequency: .inherit, target: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        nc.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)

        // Do any additional setup after loading the view.
        //textField.layer.borderWidth = 1
        postMessageView.layer.borderWidth = 1
        postMessageView.layer.borderColor = UIColor.black.cgColor
        postMessageView.layer.cornerRadius = 5
        postMessageView.backgroundColor = UIColor.white
        
        // call the 'keyboardWillShow' function when the view controller receive notification that keyboard is going to be shown
        NotificationCenter.default.addObserver(self, selector: #selector(ChatRoomVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // call the 'keyboardWillHide' function when the view controlelr receive notification that keyboard is going to be hidden
        NotificationCenter.default.addObserver(self, selector: #selector(ChatRoomVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.hideKeyboardWhenTappedAround()
        
        
        // Table view setup.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.white
        tableView.separatorColor = UIColor.clear
        
        // Fetch token.
        guard let token = KeychainHelper.read(service: KeychainHelper.TOKEN, account: KeychainHelper.REACHOUT) else {
            print("Could not read token from keychain")
            // TODO: Ask user to login again.
            return
        }
        self.authToken = token
        
        // Fetch UserId.
        guard let userId = KeychainHelper.read(service: KeychainHelper.USER_ID, account: KeychainHelper.REACHOUT) else {
            print("Could not read user Id from keychain")
            // TODO: Ask user to login again.
            return
        }
        self.myUserId = userId
        
        let roomName = getRoomName()
        self.roomName.text = roomName
        
        listChatMessages()
    }
    
    // List chat messages in the space.
    private func listChatMessages() {
        // Load chat rooms.
        ChatService.listMessagesInRoom(roomId: self.chatRoom.room_id, token: self.authToken, resultQueue: chatServiceQueue) { result in
            DispatchQueue.main.async {
                self.hideSpinner()
            }
            
            switch result {
            case .success(let gotMessages):
                self.messagesInRoom = gotMessages
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("list Chat messages failed with error: \(error.localizedDescription)")
            }
            
            // Scroll to the bottom of the table view.
            DispatchQueue.main.async {
                // Scroll down to bottom of table view by default.
                self.tableView.scrollToRow(at: IndexPath(row: self.messagesInRoom.count - 1, section: 0), at: .bottom, animated: true)
                
                if self.isInvitedState() {
                    self.acceptInvite.layer.borderColor = UIColor.gray.cgColor
                    self.acceptInvite.layer.borderWidth = 0.5
                    self.rejectInvite.layer.borderColor = UIColor.gray.cgColor
                    self.rejectInvite.layer.borderWidth = 0.5
                    self.inviteMessageLabel.text = self.roomName.text! + " wants to chat"
                } else {
                    self.hideAcceptOrRejectView()
                    
                    // Mark Chat Room as read for the user now.
                    self.markChatRoomAsRead()
                }
            }
        }
    }
    
    @objc private func appMovedToForeground() {
        // Start spinner.
        showSpinner()
        
        listChatMessages()
    }
    
    @objc private func appMovedToBackground() {
        chatRoomTimer?.invalidate()
    }
    
    // Start timer when view appears.
    override func viewWillAppear(_ animated: Bool) {
        chatRoomTimer = Timer.scheduledTimer(timeInterval: chatRoomIntervalSeconds, target: self, selector: #selector(chatRoomHandler), userInfo: nil, repeats: true)
    }
    
    // Handler for the fetch posts periodic timer.
    @objc func chatRoomHandler() {
        listChatMessages()
    }
    
    // Disable timer when we leave view controller.
    override func viewWillDisappear(_ animated: Bool) {
        chatRoomTimer?.invalidate()
    }
    
    // Mark chat room as read for user.
    private func markChatRoomAsRead() {
        // Load chat rooms.
        ChatService.markChatRoomAsRead(roomId: self.chatRoom.room_id, token: self.authToken, resultQueue: chatServiceQueue) { result in
            
            switch result {
            case .success(_):
               // Do nothing.
                break
            case .failure(let error):
                print("Mark chat as read failed with error: \(error.localizedDescription)")
            }
        }
    }
    
    // Must call in Main dispatch queue.
    private func hideAcceptOrRejectView() {
        self.inviteMessageLabel.isHidden = true
        self.acceptOrRejectStackView.isHidden = true
    }
    
    // Public method to set chat room to given room.
    func setRoom(chatRoom: ChatService.ChatRoom) {
        self.chatRoom = chatRoom
    }
    
    // Get Room name, should be the username of other person.
    private func getRoomName() -> String {
        for user in self.chatRoom.users {
            if user.user_id != self.myUserId {
                return user.username
            }
        }
        
        // Should not reach here.
        raise(-1)
        return ""
    }
    
    @IBAction func acceptChatInvite(_ sender: Any) {
        acceptOrRejectChat(accepted: true)
    }
    
    
    @IBAction func rejectChatInvite(_ sender: Any) {
        acceptOrRejectChat(accepted: false)
    }
    
    // Helper method to accept or reject chat request. Run in main thread.
    private func acceptOrRejectChat(accepted: Bool) {
        self.showSpinner()
        
        // Accept or request invite request.
        ChatService.acceptOrRejectChat(roomId: self.chatRoom.room_id, accepted: accepted, token: self.authToken, resultQueue: chatServiceQueue) { result in
            DispatchQueue.main.async {
                self.hideSpinner()
            }
            
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    // Hide the buttons.
                    self.hideAcceptOrRejectView()
                    
                    if(!accepted) {
                        // Dismiss chat room since uer rejected the request.
                        self.dismiss(animated: true)
                    }
                    // Mark chat room as read and reload it to get the updated invited state.
                    self.markChatRoomAsRead()
                    self.reloadChatRoom()
                }
            case .failure(let error):
                print("accept or reject Chat messages failed with error: \(error.localizedDescription)")
            }
        }
    }
    
    // Reloads current chat room state.
    private func reloadChatRoom() {
        // Load chat rooms and filter only the current one.
        // TODO: Create endpoint to only return 1 chat room instead of all of them.
        ChatService.listChatRooms(token: self.authToken, resultQueue: chatServiceQueue) { result in
            DispatchQueue.main.async {
                self.hideSpinner()
            }
            
            switch result {
            case .success(let gotChatRooms):
                let gotRoom = gotChatRooms.filter({$0.room_id == self.chatRoom.room_id})[0]
                self.chatRoom = gotRoom
            case .failure(let error):
                print("Reload Chats failed with error: \(error.localizedDescription)")
            }
        }
    }
    
    // Returns true if self user is invited else false.
    private func isInvitedState() -> Bool {
        return self.chatRoom.users.filter({$0.user_id == self.myUserId})[0].state == Utils.ChatUserState.INVITED.rawValue
    }
    
    // Handler for when user posts a message.
    @IBAction func didSendMessage(_ sender: Any) {
        /*guard let message = textField.text else {
            return
        }*/
        let message = postMessageView.text.description
        
        if message == "" {
            // TODO: Show error since message cannot be empty.
            return
        }
        
        // Add to messages in room.
        postChatMessage(message: message)
        
        // Clear text field.
        self.postMessageView.text = ""
    }
    
    // Post message to server.
    private func postChatMessage(message: String) {
        // Load chat rooms and filter only the current one.
        // TODO: Create endpoint to only return 1 chat room instead of all of them.
        ChatService.postChatMessage(roomId: self.chatRoom.room_id, message: message, token: self.authToken, resultQueue: chatServiceQueue) { result in
            
            switch result {
            case .success(_):
                // Load chat messages in room.
                // TODO: Load only unread messages
                self.listChatMessages()
            case .failure(let error):
                print("Reload Chats failed with error: \(error.localizedDescription)")
            }
        }
        
    }
    
    // Show loading spinner.
    private func showSpinner() {
        activityIndicator.startAnimating()
        loadingView.isHidden = false
    }

    // Hide loading spinner.
    private func hideSpinner() {
        activityIndicator.stopAnimating()
        loadingView.isHidden = true
    }

    @IBAction func back(_ sender: Any) {
        // Reload chats.
        self.dismiss(animated: true)
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
    
}

extension ChatRoomVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesInRoom.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = self.messagesInRoom[indexPath.row]
        
        if message.sender_id != self.myUserId {
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
