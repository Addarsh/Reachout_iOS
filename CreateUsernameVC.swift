//
//  CreateUsernameVC.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 10/16/22.
//

import UIKit

class CreateUsernameVC: UIViewController {

    @IBOutlet weak var loadingView: UIView! {
        didSet {
            loadingView.layer.cornerRadius = 6
            loadingView.isHidden = true
        }
    }
    
    @IBOutlet weak var usernameTextField: UITextField! {
        didSet {
            let grayPlaceholderText = NSAttributedString(string: "Username",
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
            
            usernameTextField.attributedPlaceholder = grayPlaceholderText
        }
    }
    
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        usernameTextField.layer.borderWidth = 1
        usernameTextField.layer.borderColor = UIColor.gray.cgColor
        usernameTextField.layer.cornerRadius = 5
        usernameTextField.delegate = self
        
        // Disabled by default.
        createButton.isEnabled = false
        
        self.hideKeyboardWhenTappedAround()
    }
    
    // Create new username.
    @IBAction func submit(_ sender: Any) {
        if usernameTextField.text == nil {
            return
        }
        let username = usernameTextField.text!
        
        guard let token = KeychainHelper.read(service: KeychainHelper.TOKEN, account: KeychainHelper.REACHOUT) else {
            print("Could not read token from keychain")
            // TODO: Ask user to login again.
            return
        }
        
        showSpinner()
        
        AuthService.createUsername(username: username, token: token) { result in
            DispatchQueue.main.async {
                self.hideSpinner()
            }
            
            switch result {
            case .success(let gotResp):
                // Save username to keychain.
                if gotResp.error_message != "" {
                    // Show error.
                    self.present(Utils.createOkAlert(title: "Error", message: gotResp.error_message), animated: true, completion: nil)
                    return
                }
                
                // Save username in keychain.
                KeychainHelper.save(sensitiveData: username, service: KeychainHelper.USERNAME, account: KeychainHelper.REACHOUT)
                
                DispatchQueue.main.async {
                    // Go to Tabs screen.
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "TabsVC")
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            case .failure(let error):
                print("create username failed with error: \(error.localizedDescription)")
                self.present(Utils.createOkAlert(title: "Error", message: "Unknown error occured."), animated: true, completion: nil)
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

extension CreateUsernameVC: UITextFieldDelegate {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(CreateUsernameVC.dismissKeyboard))
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
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text != nil && textField.text != "" {
            // Enable button.
            createButton.isEnabled = true
        } else {
            // Disable button.
            createButton.isEnabled = false
        }
    }
}
