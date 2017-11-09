//
//  ViewController.swift
//  gameofchats
//
//  Created by Денис Попов on 05.05.17.
//  Copyright © 2017 Денис Попов. All rights reserved.
//

import UIKit
import Firebase


class MessagesController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        

        
       //создание кнопки логаут с указанием селектора
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        //создание кнопки новых сообщений
        let image = UIImage(named : "new_msg")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
        
    }

    
    @objc func handleNewMessage () {
    let newMessageController = NewMessageController()
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
        
    }
    
    func checkIfUserIsLoggedIn () {
        //проверка ,что пользователь не авторизован
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            if let dictionary = snapshot.value as? [String : AnyObject]{
                self.navigationItem.title = dictionary["name"] as? String
            }
            
        }, withCancel: nil)
        }

    }
    
    //чтобы не было ошибок пишем функцию для селектора, создавая экземпляр логин котроллера и выполняем презент
    @objc func handleLogout() {
        
        do {
           try Auth.auth().signOut()
        }catch let logoutError{
        print(logoutError)
        }
        
    let loginController = LoginController()
    present(loginController, animated: true, completion: nil)
    
    }

}

