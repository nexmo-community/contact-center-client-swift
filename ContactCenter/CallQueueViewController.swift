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
    
    var conversations = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Call Queue"

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.loadQueue()
        }
        
        tableView.alpha = 0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
    }
    
    

    func loadQueue() {
        activityIndicatorView.startAnimating()
        activityLabel.text = "Loading the queue..."
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell")
        cell?.textLabel?.text = conversations[indexPath.row]
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}

extension CallQueueViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        getConversationInfo(conversation_id: conversations[indexPath.row])
    }
    
    func getConversationInfo(conversation_id: String) {
        print("📣📣📣 conversation selected: \(conversation_id)")
        client.getConversationWithId(conversation_id) { (error, conversation) in
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
            }
        }
    }
}
