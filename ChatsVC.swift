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
    
    // Chat Room names on the page.
    //var chatRooms: [String] = ["abc, def", "hello, everyone", "xyz, share", "asdaisjdasldalsjdlajdlajdljadljaldjaldjslajdlsajdlsajdlasj"]
    
    var chatRooms: [ChatService.ChatRoom] = []
    
    private let chatServiceQueue = DispatchQueue(label: "Chat service queue", qos: .default, attributes: [], autoreleaseFrequency: .inherit, target: nil)

    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chatRoom = chatRooms[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoomTableViewCell") as! ChatRoomTableViewCell
        
        cell.setName(name: chatRoom.name)
        
        return cell
    }
    
    // When a Chat Room is selected by user, enter Chat Room.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatRoom = chatRooms[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChatRoomVC") as! ChatRoomVC
        vc.chatRoomName = chatRoom.name
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
}
