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
    }
    
    var messages = [Message]()
    var messagesDictionary = [String : Message]()
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesReference = Database.database().reference().child("messages").child(messageId)
            
            messagesReference.observe(.value, with: { (snapshot) in
                print(snapshot)
                if let dictionary = snapshot.value as? [String : String] {
                    let message = Message()
                    message.setValuesForKeys(dictionary)
                    if let toId = message.toId {
                        self.messagesDictionary[toId] = message
                        self.messages = Array(self.messagesDictionary.values)
                        self.messages.sort(by: { (message1, message2) -> Bool in
                            return Int(message1.timestamp!)! > Int(message2.timestamp!)!
                        })
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }

    func observeMessages() {
        let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            if let snapshotValue = snapshot.value as? [String : String] {
                let message = Message()
                message.setValuesForKeys(snapshotValue)
//                self.messages.append(message)
                if let toId = message.toId {
                    self.messagesDictionary[toId] = message
                    self.messages = Array(self.messagesDictionary.values)
                    self.messages.sort(by: { (message1, message2) -> Bool in
                        return Int(message1.timestamp!)! > Int(message2.timestamp!)!
                    })
                }
                //без асинхронности будет падать приложение потому что это не основной поток
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
        }
            , withCancel: nil)
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
        
    let loginController = LoginController()
        loginController.messages = self
    present(loginController, animated: true, completion: nil)
    
    }

}

