//
//  ViewController.swift
//  gameofchats
//
//  Created by Денис Попов on 05.05.17.
//  Copyright © 2017 Денис Попов. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController,UIGestureRecognizerDelegate {

    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        
       //создание кнопки логаут с указанием селектора
        navigationItem.leftBarButtonItem =
            UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
//            UIBarButtonItem(title: "test", style: .plain, target: self, action: #selector(showChatControllerForUser))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        //создание кнопки новых сообщений
        let image = UIImage(named : "new_msg")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
//        observeMessages()
        
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let message = self.messages[indexPath.row]
        
        if let chatPartnerId = message.chatPartnerId() {
            Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
                if error != nil {
                    print("Failed to delete message:" , error as Any)
                    return
                }
                self.messagesDictionary.removeValue(forKey: chatPartnerId)
                self.attemptReloadOfTable()
                //не самый безопасный способ удалять и обновлять
//                self.messages.remove(at: indexPath.row)
//                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            })
        }
    }
    
    var messages = [Message]()
    var messagesDictionary = [String : Message]()
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                let messageId = snapshot.key
                self.fetchMessageWithMessageId(messageId : messageId )
                
            }, withCancel: nil) 
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
             print(snapshot.key)
            print(self.messagesDictionary)
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadOfTable()
        }, withCancel: nil)
        
    }
    
    private func fetchMessageWithMessageId(messageId : String) {
        
        let messagesReference = Database.database().reference().child("messages").child(messageId)
        
        messagesReference.observe(.value, with: { (snapshot) in
            print(snapshot)
            if let dictionary = snapshot.value as? [String : String] {
                let message = Message(dictionary : dictionary as [String : AnyObject])
                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                }
                
                //делаем таймер для обновления tableView (фикс отоюражения не тех фото у далогов и тд
                self.attemptReloadOfTable()
                
                
            }
        }, withCancel: nil)
    }
    
    private func attemptReloadOfTable() {
        
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
        
    }
    
    var timer : Timer?
    
    @objc private func handleReloadTable() {
        
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            guard let message1 = message1.timestamp?.intValue else {return false}
            guard let message2 = message2.timestamp?.intValue else {return false}
            return message1 > message2

        })
        
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId )
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatPartnerId() else {return}
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observe(.value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String : AnyObject] else {return}
            
            let user = User()
            user.id = chatPartnerId
            user.setValuesForKeys(dictionary)
            self.showChatControllerForUser(user: user)
        }, withCancel: nil)
        
    }
    
    @objc func handleNewMessage () {
    let newMessageController = NewMessageController()
        newMessageController.messangesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn () {
        //проверка ,что пользователь не авторизован
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
//            print(snapshot)
            if let dictionary = snapshot.value as? [String : AnyObject]{
//                self.navigationItem.title = dictionary["name"] as? String
                let user = User()
                user.setValuesForKeys(dictionary)
                self.setupNavBarWithUser(user: user)
            }
            
        }, withCancel: nil)
    }
    
    func setupNavBarWithUser(user: User) {
        
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        observeUserMessages()
        
        self.navigationItem.title  = user.name
        let titleView = UIView()
        
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        if let profileImageUrl = user.profileImageURL {
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        containerView.addSubview(profileImageView)
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor , constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
        
//        let myTapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(showChatController))
//        titleView.addGestureRecognizer(myTapGestureRecogniser)
    }
    
    @objc func showChatControllerForUser(user : User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    //чтобы не было ошибок пишем функцию для селектора, создавая экземпляр логин котроллера и выполняем презент
    @objc func handleLogout() {
        
        do {
           try Auth.auth().signOut()
        }catch let logoutError{
        print(logoutError)
        }
        
    let loginController = LoginController(collectionViewLayout: UICollectionViewFlowLayout())
        loginController.messages = self
    present(loginController, animated: true, completion: nil)
    
    }

}

