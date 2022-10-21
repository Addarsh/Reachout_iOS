//
//  VerifyEmailVC.swift
//  reachout_ios
//
//  Created by Addarsh Chandrasekar on 10/19/22.
//

import UIKit

class VerifyEmailVC: UIViewController {
    
    @IBOutlet weak var loadingView: UIView! {
        didSet {
            loadingView.layer.cornerRadius = 6
            loadingView.isHidden = true
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var otpTextField: UITextField!
    
    private let authServiceQueue = DispatchQueue(label: "Auth service queue", qos: .default, attributes: [], autoreleaseFrequency: .inherit, target: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        otpTextField.layer.borderWidth = 1
        otpTextField.layer.borderColor = UIColor.gray.cgColor
        otpTextField.layer.cornerRadius = 5
        otpTextField.delegate = self
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func verifiy(_ sender: Any) {
        if otpTextField.text == nil {
            return
        }
        let otp = otpTextField.text!
        
        guard let token = KeychainHelper.read(service: KeychainHelper.TOKEN, account: KeychainHelper.REACHOUT) else {
            print("Could not read token from keychain")
            // TODO: Ask user to login again.
            return
        }
        
        showSpinner()
        
        AuthService.verifyEmail(otp: otp, token: token, resultQueue: authServiceQueue) { result in
            DispatchQueue.main.async {
                self.hideSpinner()
            }
            
            switch result {
            case .success(let gotResp):
                // Save username to keychain.
                if gotResp.error_message != "" {
                    DispatchQueue.main.async {
                        // Show error.
                        self.present(Utils.createOkAlert(title: "Error", message: gotResp.error_message), animated: true, completion: nil)
                        return
                    }
                }
                
                // Save that email is verified in keychain.
                KeychainHelper.save(sensitiveData: Utils.EMAIL_VERIFIED_STRING, service: KeychainHelper.EMAIL_VERIFIED, account: KeychainHelper.REACHOUT)
                
                DispatchQueue.main.async {
                    // Go to Create Username screen.
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "CreateUsernameVC")
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            case .failure(let error):
                print("verify email failed with error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.present(Utils.createOkAlert(title: "Error", message: "Failed to verify code."), animated: true, completion: nil)
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
}

extension VerifyEmailVC: UITextFieldDelegate {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(VerifyEmailVC.dismissKeyboard))
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
