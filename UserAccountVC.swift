//
//  UserAccountVC.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/30/22.
//

import UIKit

class UserAccountVC: UIViewController {
    
    enum ActionType: String {
        case Feedback
        case Logout
        case DeleteAccount
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emailTitle: UILabel!
    
    let options: [ActionType] = [.Feedback, .Logout, .DeleteAccount]
    
    private let authServiceQueue = DispatchQueue(label: "Auth service queue", qos: .default, attributes: [], autoreleaseFrequency: .inherit, target: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        
        // Fetch email.
        guard let email = KeychainHelper.read(service: KeychainHelper.EMAIL, account: KeychainHelper.REACHOUT) else {
            print("Could not read email from keychain")
            // TODO: Ask user to login again.
            return
        }
        
        DispatchQueue.main.async {
            self.emailTitle.text = email
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}

extension UserAccountVC: UITableViewDataSource, UITableViewDelegate {
    // Sets cell row height.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    // Called everytime a cell appears and it will display the data in that cell.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = options[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserAccountTableViewCell") as! UserAccountTableViewCell
        
        cell.setMessage(title: option.rawValue)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let actionType = options[indexPath.row]
        switch actionType {
        case ActionType.Feedback:
            provideFeedback()
        case ActionType.Logout:
            logout()
        case ActionType.DeleteAccount:
            self.present(Utils.createDeleteAlert(handleDeleteAction), animated: true)
        }
    }
    
    // Provide app feedback.
    private func provideFeedback() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FeedbackVC") as! FeedbackVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    // Logs a user out.
    private func logout() {
        // Delete token, userId and email and go to login screen.
        KeychainHelper.delete(service: KeychainHelper.TOKEN, account: KeychainHelper.REACHOUT)
        KeychainHelper.delete(service: KeychainHelper.USER_ID, account: KeychainHelper.REACHOUT)
        KeychainHelper.delete(service: KeychainHelper.EMAIL, account: KeychainHelper.REACHOUT)
        KeychainHelper.delete(service: KeychainHelper.USERNAME, account: KeychainHelper.REACHOUT)
        KeychainHelper.delete(service: KeychainHelper.EMAIL_VERIFIED, account: KeychainHelper.REACHOUT)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    func handleDeleteAction(action: UIAlertAction) {
        guard let title = action.title else {
            return
        }
        if title == Utils.DeleteAction.Yes.rawValue {
            deleteAccount()
        }
    }
    
    // Delete a user's account and associated data.
    func deleteAccount() {
        // Fetch token.
        guard let token = KeychainHelper.read(service: KeychainHelper.TOKEN, account: KeychainHelper.REACHOUT) else {
            print("Could not read token from keychain")
            // TODO: Ask user to login again.
            return
        }
        
        AuthService.deleteAccount(token: token, resultQueue: authServiceQueue) { result in
            switch result {
            case .success(let response):
                if response.error_message != "" {
                    DispatchQueue.main.async {
                        self.present(Utils.createOkAlert(title: "Error", message: response.error_message), animated: true)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    // Logout of app.
                    self.logout()
                }
            case .failure(let error):
                print("User Account deletion failed with error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.present(Utils.createOkAlert(title: "Error", message: "Failed to delete account"), animated: true)
                }
            }
        }
    }
    
}
