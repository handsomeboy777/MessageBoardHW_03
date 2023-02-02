//
//  MessageTableViewCell.swift
//  MessageBoard
//
//  Created by imac-2437 on 2023/1/17.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var messagePeopleLable: UILabel!
    @IBOutlet weak var messageLable: UILabel!
    
    static let idenrifier = "MessageTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
