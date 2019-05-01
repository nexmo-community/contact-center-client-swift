//
//  UserSelectionViewController.swift
//  ContactCenter
//
//  Created by Paul Ardeleanu on 01/05/2019.
//  Copyright © 2019 Nexmo. All rights reserved.
//

import UIKit

class UserSelectionViewController: UIViewController {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var loginJaneButton: UIButton!
    @IBOutlet weak var loginJoeButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if Constant.apiKey.count == 0 {
            activityIndicatorView.stopAnimating()
            activityLabel.text = "Please add your API key to the Constants.swift file"
            loginJaneButton.alpha = 0
            loginJoeButton.alpha = 0
            return
        }
        if Constant.apiServerURL.count == 0 {
            activityIndicatorView.stopAnimating()
            activityLabel.text = "Please add the API server URL to the Constants.swift file"
            loginJaneButton.alpha = 0
            loginJoeButton.alpha = 0
            return
        }
        activityIndicatorView.stopAnimating()
        activityLabel.text = "Please select a user"
        loginJaneButton.alpha = 1
        loginJoeButton.alpha = 1
    }
    
    
    @IBAction func logInAsJane(_ sender: Any) {
        getToken(for: "Jane")
    }
    
    @IBAction func logInAsJoe(_ sender: Any) {
        getToken(for: "Joe")
    }
    
    
    func getToken(for userName: String) {
        activityIndicatorView.startAnimating()
        activityLabel.text = "Logging in..."
        loginJaneButton.alpha = 0
        loginJoeButton.alpha = 0
        
        ApiClient.shared.tokenFor(userName: userName, sucessResponse: { [weak self] (userName, userId, token, expiryDate) in
            // token retrieved
            print(" 🎟🎟🎟 TOKEN RETRIEVED: \(token)")
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.activityLabel.text = "Token retrieved"
                self.performSegue(withIdentifier: "showMain", sender: token)
            }
        }) { (error) in
            // token error
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.activityIndicatorView.stopAnimating()
                self.activityLabel.text = "Could not retrieve token. Please try selecting a user again..."
                self.loginJaneButton.alpha = 1
                self.loginJoeButton.alpha = 1
            }
        }
    }

    func logout() {
        activityIndicatorView.stopAnimating()
        activityLabel.text = "Please select a user"
        self.loginJaneButton.alpha = 1
        self.loginJoeButton.alpha = 1
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMain", let destination = segue.destination as? MainViewController, let token = sender as? String {
            destination.token = token
            destination.userSelectionVC = self
        }
    }
 

}
