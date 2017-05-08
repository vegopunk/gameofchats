//
//  NewMessageController.swift
//  gameofchats
//
//  Created by Денис Попов on 08.05.17.
//  Copyright © 2017 Денис Попов. All rights reserved.
//

import UIKit
import Firebase


class NewMessageController: UITableViewController {

    let cellId = "cellid"
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //добавили кнопки cancel
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        fetchUser()
        
    }
    //достаем юзеров из базы данных
    func fetchUser() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let user = User()
                user.setValuesForKeys(dictionary)
                self.users.append(user)
                self.tableView.reloadData()
            }
            

        }, withCancel: nil)
    
    }
    
    //возврат на предыдущий view controller
    func handleCancel () {
        dismiss(animated: true, completion: nil)
    }
    //обязательная функция для table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    //обязательная функция для table view
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
// let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let user = users[indexPath.row]
        //тут составляется вид ячеек каждого юзера
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        return cell
    }
}
//инициализация ячейки юзера
class UserCell : UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}













