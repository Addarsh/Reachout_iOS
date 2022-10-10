//
//  ChatsVC.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/21/22.
//

import UIKit

class ChatsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var loadingView: UIView! {
        didSet {
            loadingView.layer.cornerRadius = 6
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var chatRooms: [ChatService.ChatRoom] = []
    
    private let chatServiceQueue = DispatchQueue(label: "Chat service queue", qos: .default, attributes: [], autoreleaseFrequency: .inherit, target: nil)
    
    private var myUserId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch UserId.
        guard let userId = KeychainHelper.read(service: KeychainHelper.USER_ID, account: KeychainHelper.REACHOUT) else {
            print("Could not read user Id from keychain")
            // TODO: Ask user to login again.
            return
        }
        self.myUserId = userId

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.white
    
        // Fetch chat rooms.
        showSpinner()
        
        listChatRooms()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Used to deselect chat row when the view appears after child controller is dismissed.
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }
    
    private func listChatRooms() {
        // Fetch token.
        guard let token = KeychainHelper.read(service: KeychainHelper.TOKEN, account: KeychainHelper.REACHOUT) else {
            print("Could not read token from keychain")
            // TODO: Ask user to login again.
            return
        }
        
        // Load chat rooms.
        ChatService.listChatRooms(token: token, resultQueue: chatServiceQueue) { result in
            DispatchQueue.main.async {
                self.hideSpinner()
            }
            
            switch result {
            case .success(let gotChatRooms):
                self.chatRooms = gotChatRooms
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("list Chats failed with error: \(error.localizedDescription)")
            }
        }
    }
    
    // Get Room name.
    private func getRoomName(chatRoom: ChatService.ChatRoom) -> String {
        // Set to username of the other user.
        for user in chatRoom.users {
            if user.user_id != self.myUserId {
                return user.username
            }
        }
        
        // Should never reach this line.
        raise(-1)
        return ""
    }
    
    @IBAction func gotToAccount(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserAccountVC")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
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
}

extension ChatsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chatRoom = chatRooms[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoomTableViewCell") as! ChatRoomTableViewCell
        
        cell.setName(name: getRoomName(chatRoom: chatRoom), numUnreadMessages: chatRoom.num_unread_messages)
        
        return cell
    }
    
    // When a Chat Room is selected by user, enter Chat Room.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatRoom = chatRooms[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChatRoomVC") as! ChatRoomVC
        vc.setRoom(chatRoom: chatRoom)
        vc.chatRoomDelegate = self
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

extension ChatsVC: ChatRoomDelegate {
    func reloadChatRooms() {
        listChatRooms()
    }
}
