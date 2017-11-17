//
//  LoginController+handlers.swift
//  gameofchats
//
//  Created by Денис Попов on 08.05.17.
//  Copyright © 2017 Денис Попов. All rights reserved.
//

import UIKit
import Firebase

extension LoginController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    
    
    //селектор для кнопки регистрации
    func handleRegister() {
        
        guard let email = emailTextField.text , let password = passwordTextField.text , let name = nameTextField.text else {
            print("Form is not valid")
            return
        }
        
//        Auth.auth().createUser(withEmail: email, password: password, completion: {(user : User? , error) in
//            if error != nil {
//                print(error!)
//                return
//            }
//            //успешно зарегестрированный пользователь
//
//            //уникальные идентификатор для каждого пользователя
//            //сделали для сокращения кода
//            guard let uid = user?.uid else {
//                return
//            }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error!)
                return
            }
            guard let uid = user?.uid else {return}
        
            //отправка картинки в хранилище firebase
            //уникальное название для всех загружаемых картинок
            let imageName = NSUUID().uuidString
            //ссылка на хранилище firebase
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
            
            if let profileImage = self.profileImageView.image , let uploadData = UIImageJPEGRepresentation(profileImage, 0.1){
                
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                let values = ["name" : name , "email" : email , "profileImageURL" : profileImageUrl]
                    
//                self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                    registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                }
            })
            }
    }

    
    func registerUserIntoDatabaseWithUID (uid : String , values : [String : AnyObject]) {
        //ссылка на нашу базу данных в firebase
        let ref = Database.database().reference()
        //добавляется для уникальной записи в базе данных для каждого пользователя
        let userReference = ref.child("users").child(uid)
        
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err!)
                return
            }
            
//            self.messages?.fetchUserAndSetupNavBarTitle()
//            self.messages?.navigationItem.title = values["name"] as? String
            let user = User()
            user.setValuesForKeys(values)
            self.messages?.setupNavBarWithUser(user: user)
            
            self.dismiss(animated: true, completion: nil)
            //пишем о том, что пользователь успешно сохранен в базе данных Firebase
            print("Saved user successfully into Firebase DB")
        })

    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker : UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
        selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
        selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
         dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    }
}
