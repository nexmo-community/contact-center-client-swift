//
//  MainViewController.swift
//  ContactCenter
//
//  Created by Paul Ardeleanu on 01/05/2019.
//  Copyright © 2019 Nexmo. All rights reserved.
//

import UIKit
import NexmoClient


class MainViewController: UIViewController {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var activityLabel: UILabel!
    
    weak var userSelectionVC: UserSelectionViewController?
    var token: String!
    var client: NXMClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(cancel))
        
        client = NXMClient(token: token)
        client.setDelegate(self)
        client.login()
    }
    

    @objc func cancel() {
        let alertController = UIAlertController(title: "Logging our", message: "Are you sure?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self]  (_) in
            self?.logout()
        })
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alertController.view.setNeedsLayout()
        present(alertController, animated: true) { () -> Void in }
    }
    
    func logout() {
        client.logout()
        DispatchQueue.main.async { [weak self] in
            self?.userSelectionVC?.logout()
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}



extension MainViewController: NXMClientDelegate {
    
    func connectionStatusChanged(_ status: NXMConnectionStatus, reason: NXMConnectionStatusReason) {
        print("👁👁👁 connectionStatusChanged - status: \(status.description()) - reason: \(reason.description())")
        print("Client connection status: \(String(describing: client?.connectionStatus.description()))")
        updateInterface()
    }
    
    func added(to conversation: NXMConversation) {
        print("📣📣📣 added to conversation: \(conversation)")
    }
    
}



extension MainViewController {
    
    func updateInterface() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.activityIndicatorView.stopAnimating()
            self.activityLabel.text = "Ready."
            self.navigationItem.rightBarButtonItem = nil
            //            self.janeLoginButton.alpha = 0
            //            self.joeLoginButton.alpha = 0
            //            self.createConversationButton.alpha = 0
            
            guard let client = self.client else {
                self.activityLabel.text = "Ready."
                //                self.janeLoginButton.alpha = 1
                //                self.joeLoginButton.alpha = 1
                return
            }
            switch client.connectionStatus {
            case .disconnected:
                self.activityLabel.text = "Disconnected"
                //                self.janeLoginButton.alpha = 1
            //                self.joeLoginButton.alpha = 1
            case .connecting:
                self.activityIndicatorView.startAnimating()
                self.activityLabel.text = "Connecting..."
            case .connected:
                //                self.janeLoginButton.alpha = 0
                //                self.joeLoginButton.alpha = 0
                //                self.createConversationButton.alpha = 1
                self.activityLabel.text = "Logged in as \(client.user?.name ?? "")"
            @unknown default:
                self.activityLabel.text = "Disconnected"
                //                self.janeLoginButton.alpha = 1
                //                self.joeLoginButton.alpha = 1
            }
        }
    }
    
}

