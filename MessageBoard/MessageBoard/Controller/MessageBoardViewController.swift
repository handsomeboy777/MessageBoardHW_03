//
//  MessageBoardViewController.swift
//  MessageBoard
//
//  Created by imac-2437 on 2023/1/17.
//

import UIKit
import RealmSwift

class MessageBoardViewController: UIViewController {
    @IBOutlet weak var messagePeopleLable: UILabel!
    @IBOutlet weak var messagePeopleTextField:UITextField!
    @IBOutlet weak var messageLable: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var messageTableView: UITableView!
    var messageArray: [Message] = []
    var optionsArray: [String] = ["預設", "舊到新" , "新到舊"]
    var rule: SortRule = .default
    
    enum SortRule {
        case `default`
        case oldToNew
        case newToold
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFromDatabase(rule: rule)
    }
    
    func setupUI() {
        setupNavigationBarStyle()
        setupNavigationBarButtonItems()
        setupLabel()
        setupButton()
        setupTableView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    private func setupLabel() {
        
        messagePeopleLable.text = "留言人"
        messageLable.text = "留言內容"
    }
    private func setupButton() {
        sendButton.setTitle("送出", for: .normal)
        sendButton.backgroundColor = .green
        sendButton.layer.cornerRadius = 10
        sortButton.setTitle("排序", for: .normal)
        sortButton.backgroundColor = .purple
        sortButton.layer.cornerRadius = 10

    }
    
    private func setupTableView() {
        messageTableView.register(UINib(nibName: "MessageTableViewCell", bundle: nil),
                                  forCellReuseIdentifier: MessageTableViewCell.idenrifier)
        messageTableView.dataSource = self
        messageTableView.delegate = self
        
    }
    
    private func setupNavigationBarStyle() {
        let apprence = UINavigationBarAppearance()
        self.navigationController?.navigationBar.standardAppearance = apprence
    }
    
    private func setupNavigationBarButtonItems() {
        let sortItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle.fill"),
                                       style: .done,
                                       target: self,
                                       action: #selector(sortBtnClicked))
        navigationItem.leftBarButtonItem = sortItem
        
        let addItem = UIBarButtonItem(image: UIImage(systemName: "plus.circle.fill"),
                                      style: .done,
                                      target: self,
                                      action: #selector(sendBtnClicked))
        navigationItem.rightBarButtonItem = addItem
    }
    
    @objc func closeKeyboard() {
        view.endEditing(true)
    }
    
    
    
    func fetchFromDatabase(rule: SortRule) {
        DispatchQueue.global().async {
            let realm = try! Realm()
            let results : Results<MessageTable>
            switch rule {
            case .default:
                results = realm.objects(MessageTable.self)
            case .oldToNew:
                results = realm.objects(MessageTable.self)
            case .newToold:
                results = realm.objects(MessageTable.self).sorted(byKeyPath: "timestamp", ascending: false)
            }
            if results.count > 0 {
                self.messageArray = []
                for i in results {
                    self.messageArray.append(Message(name: i.name,
                                                     content: i.content,
                                                     timestap: i.timestamp))
                }
                DispatchQueue.main.async {
                    self.messageTableView.reloadData()
                }
            }
        }
    }
    
    func userNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            print("成功建立通知")
        }
    }
    
    func editedMessage(message: Message) {
        self.messagePeopleTextField.text = message.name
        self.messageTextView.text = message.content
        LocalDatabase.shared.deleteMessage(message: message)
    }
    
    func showAlert(title: String?, message: String?, confirmTitle: String, confirm: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: confirmTitle, style: .default) { _ in
            confirm?()
        }
        alertController.addAction(confirmAction)
        present(alertController, animated: true)
    }
    
    func showActionSheet(title: String?,
                         message: String? ,
                         options: [String],
                         confirm: ((Int) -> Void)? = nil) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .actionSheet)
        
        for option in options {
            let index = options.firstIndex(of: option)
            let action = UIAlertAction(title: option, style: .default) { _ in
                    confirm?(index!)
            }
            alertController.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    
    @IBAction @objc func sendBtnClicked(_ sender: UIButton) {
        closeKeyboard()
        guard let messagePeople = messagePeopleTextField.text, !(messagePeople.isEmpty) else {
            showAlert(title: "錯誤", message: "請輸入留言人", confirmTitle: "關閉")
            return
        }
        guard let message = messageTextView.text, !(message.isEmpty) else {
            showAlert(title: "錯誤", message: "請輸入留言", confirmTitle: "關閉")
            return
        }
        showAlert(title: "成功", message: "留言已送出", confirmTitle: "關閉") {
            self.messagePeopleTextField.text = ""
            self.messageTextView.text = ""
        }
        
        userNotification(title: messagePeople, body: message)
        
        print("留言人：\(messagePeople)")
        print("留言內容：\(message)")
        
        let msg = Message(name: messagePeople,
                          content: message,
                          timestap: Int64(Date().timeIntervalSince1970))
        LocalDatabase.shared.addMessage(message: msg)
        fetchFromDatabase(rule: rule)
    }
    @IBAction @objc func sortBtnClicked(_ sender: UIButton) {
        showActionSheet(title: "請選擇排序方式",
                        message: "我也不知道寫什麼",
                        options: optionsArray) { index in
            switch index {
            case 0:
                print("選擇預設排序方式")
                self.rule = .default
                self.fetchFromDatabase(rule: self.rule)
            case 1:
                print("選擇舊到新排序方式")
                self.rule = .oldToNew
                self.fetchFromDatabase(rule: self.rule)
            case 2:
                self.rule = .newToold
                print("選擇新到舊排序方式")
                self.fetchFromDatabase(rule: self.rule)
            default:
                break
            }
        }
        
    }

}

extension MessageBoardViewController: UITableViewDataSource, UITableViewDelegate {
    
    //UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.idenrifier,
                                                       for: indexPath) as? MessageTableViewCell else {
            fatalError("MessageTableViewCell Load Failed")
        }
        cell.messagePeopleLable.text = "留言人：" + messageArray[indexPath.row].name
        cell.messageLable.text = "留言內容：" + messageArray[indexPath.row].content
        return cell
    }
    
    //UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    //UI 左滑
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { action, sourceView, completionHandler in
            LocalDatabase.shared.deleteMessage(message: self.messageArray[indexPath.row])
            self.fetchFromDatabase(rule: self.rule)
            self.userNotification(title: "刪除", body: "已經刪除")
            completionHandler(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemBlue
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    //右滑
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editedAction = UIContextualAction(style: .destructive, title: "編輯"){ action, sourceView, completionHandler in
            self.editedMessage(message: self.messageArray[indexPath.row])
            tableView.reloadData()
            completionHandler(true)
        }
        editedAction.image = UIImage(systemName: "pencil")
        editedAction.backgroundColor = .systemBrown
        let configuration = UISwipeActionsConfiguration(actions: [editedAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}
