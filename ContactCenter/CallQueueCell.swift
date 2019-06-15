//
//  CallQueueCell.swift
//  ContactCenter
//
//  Created by Paul Ardeleanu on 15/06/2019.
//  Copyright © 2019 Nexmo. All rights reserved.
//

import UIKit

class CallQueueCell: UITableViewCell {

    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var conversationIdLabel: UILabel!
    @IBOutlet weak var legIdLabel: UILabel!
    @IBOutlet weak var waitingTimeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateWith(conversation: QueuedConversation) {
        phoneLabel.text = conversation.msisdn
        conversationIdLabel.text = conversation.conversation_id
        legIdLabel?.text = conversation.leg_id
        let timestamp = Double(conversation.timestamp) ?? 0.0
        let timeInterval = Int(Date().timeIntervalSince1970 - timestamp)
        switch timeInterval {
        case 0...120:
            waitingTimeLabel?.text = "\(timeInterval) s"
        case 121...7200:
            waitingTimeLabel?.text = "\(timeInterval/60) mins"
        case 7201...86400:
            waitingTimeLabel?.text = "\(timeInterval/3600) h"
        default:
            waitingTimeLabel?.text = "\(timeInterval/3600) days"
        }
        
    }
}
