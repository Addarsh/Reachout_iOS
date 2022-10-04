//
//  LoginVC.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 9/27/22.
//

import UIKit

class LoginVC: UIViewController, UITextFieldDelegate  {
    
    @IBOutlet weak var loadingView: UIView! {
        didSet {
            loadingView.layer.cornerRadius = 6
            loadingView.isHidden = true
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            let grayPlaceholderText = NSAttributedString(string: "Email",
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
            
            emailTextField.attributedPlaceholder = grayPlaceholderText
        }
    }
    
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            let grayPlaceholderText = NSAttributedString(string: "Password",
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
            
            passwordTextField.attributedPlaceholder = grayPlaceholderText
        }
    }
    
    private var rightButton: UIButton!
    
    private let authServiceQueue = DispatchQueue(label: "Auth service queue", qos: .default, attributes: [], autoreleaseFrequency: .inherit, target: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor.gray.cgColor
        emailTextField.layer.cornerRadius = 5
        emailTextField.delegate = self
        
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor.gray.cgColor
        passwordTextField.layer.cornerRadius = 5
        passwordTextField.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        
        self.setUpPasswordButton()
    }

    @IBAction func login(_ sender: Any) {
        
        showSpinner()
        
        // Login.
        AuthService.loginOrSignUp(requestType: .Login, email: self.emailTextField.text!, password: self.passwordTextField.text!, resultQueue: authServiceQueue) { result in
            switch result {
            case .success(let response):
                let token = response.token
                let userId = response.user_id
                
                // Save token and userId to keychain.
                KeychainHelper.save(sensitiveData: token, service: KeychainHelper.TOKEN, account: KeychainHelper.REACHOUT)
                KeychainHelper.save(sensitiveData: userId, service: KeychainHelper.USER_ID, account: KeychainHelper.REACHOUT)
                
                DispatchQueue.main.async {
                    // Go to Posts screen.
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "TabsVC")
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            case .failure(let error):
                print("User login failed with error: \(error.localizedDescription)")
            }
            
            DispatchQueue.main.async {
                self.hideSpinner()
            }
        }
    }
    
    @IBAction func signUpInstead(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SignUpVC")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    // Set up button to show/hide password field.
    private func setUpPasswordButton() {
        let rightButton  = UIButton(type: .custom)
        rightButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        rightButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        rightButton.frame = CGRect(x: CGFloat(passwordTextField.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        rightButton.backgroundColor = UIColor.white
        rightButton.addTarget(self, action: #selector(self.togglePasswordView), for: .touchUpInside)
        self.rightButton = rightButton
        
        passwordTextField.rightView = rightButton
        passwordTextField.rightViewMode = .always
        passwordTextField.isSecureTextEntry = true
    }
    
    @IBAction func togglePasswordView() {
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
        if passwordTextField.isSecureTextEntry {
            self.rightButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        } else {
            self.rightButton.setImage(UIImage(systemName: "eye"), for: .normal)
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

extension LoginVC {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginVC.dismissKeyboard))
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
