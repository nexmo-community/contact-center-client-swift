//
//  MainViewController.swift
//  ContactCenter
//
//  Created by Paul Ardeleanu on 01/05/2019.
//  Copyright © 2019 Nexmo. All rights reserved.
//

import UIKit
import NexmoClient


enum CallStatus {
    case ready
    case initiated
    case inProgress
    case error
    case rejected
    case completed
}


class MainViewController: UIViewController {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var callPhoneButton: UIButton!
    
    weak var userSelectionVC: UserSelectionViewController?
    var user: NexmoUser!
    var client: NXMClient!
    var call: NXMCall?
    var callStatus: CallStatus = .ready
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(cancel))
        
        client = NXMClient(token: user.token)
        client.setDelegate(self)
        client.login()
    }

    @objc func cancel() {
        let alertController = UIAlertController(title: "Logging out", message: "Are you sure?", preferredStyle: .alert)
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
    
    
    @IBAction func callPhone(_ sender: Any) {
        if let call = self.call {
            call.hangup()
            updateInterface()
            return
        }
        self.callStatus = .initiated
        self.updateInterface()
        client?.call([Constant.callee], callHandler: .server, delegate: self) { [weak self] (error, call) in
            guard let self = self else { return }
            // Handle create call failure
            guard let call = call else {
                if let error = error {
                    // Handle create call failure
                    print("❌❌❌ call not created: \(error.localizedDescription)")
                } else {
                    // Handle unexpected create call failure
                    print("❌❌❌ call not created: unknown error")
                }
                self.callStatus = .error
                self.call = nil
                self.updateInterface()
                return
            }
            
            // Handle call created successfully.
            // callDelegate's  statusChanged: will be invoked with needed updates.
            self.callStatus = .initiated
            call.setDelegate(self)
            self.call = call
            self.updateInterface()
        }
    }
    

}



extension MainViewController {
    
    func updateInterface() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.activityIndicatorView.stopAnimating()
            self.activityLabel.text = "Ready."
            self.navigationItem.rightBarButtonItem = nil
            self.callPhoneButton.alpha = 0
            
            guard let client = self.client else {
                self.activityLabel.text = "Ready."
                return
            }
            switch client.connectionStatus {
            case .disconnected:
                self.activityLabel.text = "Disconnected"
                return
            case .connecting:
                self.activityIndicatorView.startAnimating()
                self.activityLabel.text = "Connecting..."
                return
            case .connected:
                self.activityLabel.text = "Logged in as \(client.user?.name ?? "")"
            @unknown default:
                self.activityLabel.text = "Disconnected"
                return
            }
            
            switch self.callStatus {
            case .ready:
                self.activityLabel.text = "Ready"
                self.callPhoneButton.setTitle("Call Phone", for: .normal)
                self.callPhoneButton.alpha = 1
            case .initiated:
                self.activityIndicatorView.startAnimating()
                self.activityLabel.text = "Calling..."
                self.callPhoneButton.setTitle("End Call", for: .normal)
                self.callPhoneButton.alpha = 1
            case .inProgress:
                self.activityLabel.text = "Speaking..."
                self.callPhoneButton.setTitle("End Call", for: .normal)
                self.callPhoneButton.alpha = 1
            case .error:
                self.activityLabel.text = "Error Calling"
                self.callPhoneButton.setTitle("Call Phone", for: .normal)
                self.callPhoneButton.alpha = 1
            case .rejected:
                self.activityLabel.text = "Call Rejected"
                self.callPhoneButton.setTitle("Call Phone", for: .normal)
                self.callPhoneButton.alpha = 1
            case .completed:
                self.activityLabel.text = "Call Completed"
                self.callPhoneButton.setTitle("Call Phone", for: .normal)
                self.callPhoneButton.alpha = 1
            }
        }
    }
    
}





//MARK:- Client Delegate

extension MainViewController: NXMClientDelegate {
    
    func connectionStatusChanged(_ status: NXMConnectionStatus, reason: NXMConnectionStatusReason) {
        print("👁👁👁 connectionStatusChanged - status: \(status.description()) - reason: \(reason.description())")
        print("Client connection status: \(String(describing: client?.connectionStatus.description()))")
        updateInterface()
    }
    
    func added(to conversation: NXMConversation) {
        print("📣📣📣 added to conversation: \(conversation)")
    }
    
    
    func incomingCall(_ call: NXMCall) {
        print("📲 📲 📲 Incoming Call: \(call)")
        callStatus = .initiated
        updateInterface()
        DispatchQueue.main.async { [weak self] in
            self?.displayIncomingCallAlert(call: call)
        }
    }
    
    func displayIncomingCallAlert(call: NXMCall) {
        let names: [String] = call.otherCallMembers.compactMap({ participant -> String? in
            return (participant as? NXMCallMember)?.user.displayName ?? (participant as? NXMCallMember)?.user.name
        })
        var message = names.joined(separator: ", ")
        if let otherParty = call.otherCallMembers.firstObject as? NXMCallMember, otherParty.channelType == "phone", let phoneNumber = otherParty.phoneNumber {
            message = "+\(phoneNumber)"
        }
        let alert = UIAlertController(title: "Incoming call from", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Answer", style: .default, handler: { _ in
            self.answer(call: call)
        }))
        alert.addAction(UIAlertAction(title: "Reject", style: .default, handler: { _ in
            self.reject(call: call)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    private func answer(call: NXMCall) {
        self.call = call
        self.call?.setDelegate(self)
        call.answer(self) { [weak self] error in
            if let error = error {
                print("error answering call: \(error.localizedDescription)")
            }
            self?.callStatus = .inProgress
            self?.updateInterface()
        }
    }
    private func reject(call: NXMCall) {
        callStatus = .completed
        updateInterface()
        call.reject { [weak self] error in
            if let error = error {
                print("error declining call: \(error.localizedDescription)")
            }
            self?.updateInterface()
        }
    }
    
}






//MARK:- Call Delegate

extension MainViewController: NXMCallDelegate {
    
    func statusChanged(_ member: NXMCallMember) {
        print("🤙🤙🤙 Call Status changed | member: \(String(describing: member.user.displayName)) | \(String(describing: member.user.userId))")
        print("🤙🤙🤙 Call Status changed | member status: \(String(describing: member.status.description()))")
        
        guard let call = call else {
            // this should never happen
            self.callStatus = .ready
            self.updateInterface()
            return
        }
        
        // call completed
        if member == call.myCallMember, member.status == .completed {
            self.callStatus = .completed
            self.call?.myCallMember.hangup()
            self.call = nil
        }

        // call ended before it could be answered
        if member == call.myCallMember, member.status == .answered, let otherMember = call.otherCallMembers.firstObject as? NXMCallMember, [NXMCallMemberStatus.completed, NXMCallMemberStatus.cancelled].contains(otherMember.status)  {
            self.callStatus = .completed
            self.call?.myCallMember.hangup()
            self.call = nil
        }

        // call rejected
        if call.otherCallMembers.contains(member), member.status == .cancelled {
            self.callStatus = .rejected
            self.call?.myCallMember.hangup()
            self.call = nil
        }

        // call ended
        if call.otherCallMembers.contains(member), member.status == .completed {
            self.callStatus = .completed
            self.call?.myCallMember.hangup()
            self.call = nil
        }

        updateInterface()
    }
    
}



