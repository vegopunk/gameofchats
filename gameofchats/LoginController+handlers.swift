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
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: {(user : FIRUser? , error) in
            if error != nil {
                print(error!)
                return
            }
            //успешно зарегестрированный пользователь
            
            //уникальные идентификатор для каждого пользователя
            //сделали для сокращения кода
            guard let uid = user?.uid else {
                return
            }
            
            
            //отправка картинки в хранилище firebase
            
            //уникальное название для всех загружаемых картинок
            let imageName = NSUUID().uuidString
            
            //ссылка на хранилище firebase
            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).png")
            
            if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!){
            storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                let values = ["name" : name , "email" : email , "profileImageURL" : profileImageUrl]
                    
                self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                }
            })
            }
        })
    }

    
    private func registerUserIntoDatabaseWithUID (uid : String , values : [String : AnyObject]) {
        //ссылка на нашу базу данных в firebase
        let ref = FIRDatabase.database().reference(fromURL: "https://gameofchats-3242d.firebaseio.com/")
        //добавляется для уникальной записи в базе данных для каждого пользователя
        let userReference = ref.child("users").child(uid)
        
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err!)
                return
            }
            
            self.dismiss(animated: true, completion: nil)
            //пишем о том, что пользователь успешно сохранен в базе данных Firebase
            print("Saved user successfully into Firebase DB")
        })

    }
    
    
    func handleSelectProfileImageView () {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        //для возможности выбора размера картинки для аватарки
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker : UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
        selectedImageFromPicker = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
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
