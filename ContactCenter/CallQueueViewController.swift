//
//  CallQueueViewController.swift
//  ContactCenter
//
//  Created by Paul Ardeleanu on 15/06/2019.
//  Copyright © 2019 Nexmo. All rights reserved.
//

import UIKit
import NexmoClient


class CallQueueViewController: UIViewController {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    weak var client: NXMClient!
    var callStatus: CallStatus = .ready
    
    
    var conversations = [QueuedConversation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Call Queue"

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.connect()
            //self?.loadQueue()
        }
        
        tableView.alpha = 0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Disconnect", style: .plain, target: self, action: #selector(cancel))
    }
    
    @objc func cancel() {
        let alertController = UIAlertController(title: "Disconnecting", message: "Are you sure?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self]  (_) in
            self?.disconnect()
        })
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alertController.view.setNeedsLayout()
        present(alertController, animated: true) { () -> Void in }
    }
    
    func disconnect() {
        call?.hangup()
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    var call: NXMCall?
    func connect() {
        activityIndicatorView.startAnimating()
        activityLabel.text = "Connecting as agent..."
        
        
        client.call(Constant.appNumber, callHandler: .server) { (error, call) in
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
                self.activityIndicatorView.stopAnimating()
                self.activityLabel.text = "Could not connect as agent..."
                self.tableView.alpha = 0
                return
            }
            
            // Handle call created successfully.
            // callDelegate's  statusChanged: will be invoked with needed updates.
            self.callStatus = .initiated
            call.setDelegate(self)
            self.call = call
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.activityIndicatorView.startAnimating()
                self.activityLabel.text = "Connecting as agent..."
                self.tableView.alpha = 0
            }
        }
    }
    
    

    @objc func loadQueue() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.activityIndicatorView.startAnimating()
            self.activityLabel.text = "Loading the queue..."
        }
        
        ApiClient.shared.conversationsQueue(sucessResponse: { [weak self] (conversations) in
            // token retrieved
            print(" 📲📲📲 Conversations RETRIEVED: \(conversations)")
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.activityLabel.text = "Conversations retrieved"
                self.conversations = conversations
                self.tableView.reloadData()
                UIView.animate(withDuration: 0.2, animations: {
                    self.activityLabel.alpha = 0
                    self.activityIndicatorView.stopAnimating()
                    self.tableView.alpha = 1
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reload", style: .plain, target: self, action: #selector(self.loadQueue))
                })
            }
        }) { (error) in
            // token error
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.activityIndicatorView.stopAnimating()
                self.activityLabel.text = "Could not retrieve the queue. Please try again..."
            }
        }
    }
    
}




//MARK:- Call Delegate

extension CallQueueViewController: NXMCallDelegate {
    func call(_ call: NXMCall, didUpdate callMember: NXMCallMember, with status: NXMCallMemberStatus) {
        statusChanged(callMember)
    }
    
    func call(_ call: NXMCall, didUpdate callMember: NXMCallMember, isMuted muted: Bool) {
                statusChanged(callMember)
        print("Call Queue - isMuted",muted)
    }
    
    func call(_ call: NXMCall, didReceive error: Error) {
        print("Call Queue - error", error)
    }
    
    
    func statusChanged(_ member: NXMCallMember) {
        print("🤙🤙🤙 Call Status changed | member: \(String(describing: member.user.displayName)) | \(String(describing: member.user.uuid))")
        print("🤙🤙🤙 Call Status changed | member status: \(String(describing: member.status.description()))")
        
        guard let call = call else {
            return
        }
        
        // call completed
        if member == call.myCallMember, member.status == .completed {
            self.cancel()
        }
        
        // call ended before it could be answered
        if member == call.myCallMember, member.status == .answered, let otherMember = call.otherCallMembers.firstObject as? NXMCallMember, [NXMCallMemberStatus.completed, NXMCallMemberStatus.canceled].contains(otherMember.status)  {
            self.cancel()
        }
        
        // call rejected
        if call.otherCallMembers.contains(member), member.status == .canceled {
            self.cancel()
        }
        
        // call ended
        if call.otherCallMembers.contains(member), member.status == .completed {
            self.cancel()
        }
        
        if member == call.myCallMember, member.status == .answered, self.conversations.count == 0 {
            self.loadQueue()
        }
    }
    
}



extension CallQueueViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell") as? CallQueueCell
        cell?.updateWith(conversation: conversations[indexPath.row])
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
}

extension CallQueueViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let conversation = conversations[indexPath.row]
        print("📣📣📣 conversation selected: \(conversation)")
        
//        self.call?.addMember(withNumber: conversation.msisdn, completionHandler: { (error) in
//            print("call add member with number - error: \(String(describing: error))")
//        })
//        self.call?.addMember(withUserId: conversation.leg_id, completionHandler: { (error) in
//            print("call add member - error: \(String(describing: error))")
//        })
//        getConversationInfo(conversation: conversations[indexPath.row])
        
        
        
    }

    
    //    MARK: - Joining user's conversation
    
    func getConversationInfo(conversation: QueuedConversation) {
        client.getConversationWithUUid(conversation.conversation_id) { [weak self] (error, conversation) in
            print("conversation error: \(String(describing: error))")
            print("conversation: \(String(describing: conversation))")

            if let error = error {
                let nexmoError = error as NSError
                DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                    let alert = UIAlertController(title: "Error", message: (nexmoError.userInfo["description"] as? String) ?? error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            } else {
                print("conversation: \(String(describing: conversation))")
                if let conversation = conversation {
                    self?.join(conversation: conversation)
                }
            }
        }
    }
    func join(conversation: NXMConversation) {
        conversation.delegate = self
        
        conversation.join { (error, member) in
            if let error = error {
                DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                    let nexmoError = error as NSError
                    let alert = UIAlertController(title: "Error", message: (nexmoError.userInfo["description"] as? String) ?? error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
                return
            }
            print("conversation joined - error: \(String(describing: error))")
            print("conversation joined - member : \(String(describing: member))")
            print("conversation joined - member.memberId : \(String(describing: member?.memberUuid))")
            print("conversation joined - member.user.name : \(String(describing: member?.user.name))")
            print("conversation joined - member state: \(String(describing: member?.state.rawValue))")
        }
    }
    
}


extension CallQueueViewController: NXMConversationDelegate {
    func conversation(_ conversation: NXMConversation, didReceive error: Error) {
        print("CONVERSATIION EVENT - error: \(String(describing: error))")

    }
    
    
    func conversation(_ conversation: NXMConversation, didReceive event: NXMMemberEvent) {
        print("CONVERSATIION EVENT - member: \(event.member.memberUuid)   |  state: \(event.state.rawValue)")
        print("                    - channel: \(event.channel?.from.type) \(event.channel?.from.data) => \(event.channel?.to?.type) \(event.channel?.to?.data)")
    }
}

