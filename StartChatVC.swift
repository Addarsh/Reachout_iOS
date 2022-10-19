//
//  StartChatVC.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 10/4/22.
//

import UIKit

class StartChatVC: UIViewController {

    @IBOutlet weak var loadingView: UIView! {
        didSet {
            loadingView.layer.cornerRadius = 6
            loadingView.isHidden = true
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var otherUserNameLabel: UILabel!
    
    @IBOutlet weak var messageView: UITextView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    var postOfCreator: PostsService.Post!
    
    let messageViewPlaceholder = "Send a chat invite message :)"
    
    private let chatServiceQueue = DispatchQueue(label: "Chat service queue", qos: .default, attributes: [], autoreleaseFrequency: .inherit, target: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        otherUserNameLabel.text = postOfCreator.username

        // Do any additional setup after loading the view.
        messageView.backgroundColor = UIColor.white
        messageView.layer.borderWidth = 1
        messageView.layer.cornerRadius = 5
        messageView.layer.borderColor = UIColor.black.cgColor
        messageView.text = messageViewPlaceholder
        messageView.textColor = UIColor.lightGray
        messageView.delegate = self
        
        submitButton.layer.cornerRadius = 10
        
        hideKeyboardWhenTappedAround()
    }
    
    // Send chat invite.
    @IBAction func submit(_ sender: Any) {
        if messageView.text == messageViewPlaceholder || messageView.text.isEmpty {
            self.present(Utils.createOkAlert(title: "Error", message: "Conversation invite message cannot be empty"), animated: true)
            return
        }
        
        // Fetch token.
        guard let token = KeychainHelper.read(service: KeychainHelper.TOKEN, account: KeychainHelper.REACHOUT) else {
            print("Could not read token from keychain")
            // TODO: Ask user to login again.
            return
        }
        
        showSpinner()
        
        // Start Chat.
        ChatService.startChat(inviteeId: postOfCreator.creator_user, initialMessage: messageView.text.description, token: token, resultQueue: chatServiceQueue) { result in
            DispatchQueue.main.async {
                self.hideSpinner()
            }
            
            switch result {
            case .success(let gotResp):
                let error_message = gotResp.error_message
                DispatchQueue.main.async {
                    if !error_message.isEmpty {
                        self.present(Utils.createOkAlert(title: "Error", message: "Failed to start conversation"), animated: true)
                        return
                    }
                    self.dismiss(animated: true)
                }
            case .failure(let error):
                print("start chat failed with error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.present(Utils.createOkAlert(title: "Error", message: "Failed to start conversation"), animated: true)
                }
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
        self.dismiss(animated: true)
    }
    
}

extension StartChatVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = messageViewPlaceholder
            textView.textColor = UIColor.lightGray
        }
    }
}

// Ensure that keyboard is dismissed when user taps anywhere in the view (outside keyboard).
extension StartChatVC {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(StartChatVC.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Hide keyboard when Enter key is pressed.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
