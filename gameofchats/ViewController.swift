//
//  ViewController.swift
//  gameofchats
//
//  Created by Денис Попов on 05.05.17.
//  Copyright © 2017 Денис Попов. All rights reserved.
//

import UIKit
import Firebase


class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        

        
       //создание кнопки логаут с указанием селектора
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        //проверка ,что пользователь не авторизован
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            
        }
        
    }

    //чтобы не было ошибок пишем функцию для селектора, создавая экземпляр логин котроллера и выполняем презент
    func handleLogout() {
        
        do {
           try FIRAuth.auth()?.signOut()
        }catch let logoutError{
        print(logoutError)
        }
        
    let loginController = LoginController()
    present(loginController, animated: true, completion: nil)
    
    }

}

