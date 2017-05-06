//
//  LoginController.swift
//  gameofchats
//
//  Created by Денис Попов on 05.05.17.
//  Copyright © 2017 Денис Попов. All rights reserved.
//

import UIKit
import Firebase
class LoginController: UIViewController {

    
    //создаем контейнер для полей ввода регистрации
    let inputsContainerView : UIView = {
    
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    //конструктор кнопки регистрации
    lazy var loginRegisterButton : UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        //добавляем таргет на кнопку регистрации
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        
        return button
    }()
    
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
            
            //ссылка на нашу базу данных в firebase
            let ref = FIRDatabase.database().reference(fromURL: "https://gameofchats-3242d.firebaseio.com/")
            //добавляется для уникальной записи в базе данных для каждого пользователя
            let userReference = ref.child("users").child(uid)
            let values = ["name" : name , "email" : email]
            userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                if err != nil {
                print(err!)
                    return
                }
                //пишем о том, что пользователь успешно сохранен в базе данных Firebase
                print("Saved user successfully into Firebase DB")
            })
        })
    }
    
    
    //конструктор поля name в конструкторе
    let nameTextField : UITextField = {
    let tf = UITextField()
    tf.placeholder = "Name"
    tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    //сепаратор между полями ввода
    let nameSeparatorView : UIView = {
    let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //конструктор поля name в конструкторе
    let emailTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    //сепаратор между полями ввода
    let emailSeparatorView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //конструктор поля password в конструкторе
    let passwordTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    
    //конструктор добавления картинки 
    let profileImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "stark")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //цвет бекграунда логин контроллера
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)
        
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupProfileImageView()
        
        
    }
    
    func setupProfileImageView () {
        
        //нужные данные для создания полей x ,y, width , height  , constraints
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        
    }
    
    func setupInputsContainerView(){
        //нужные данные для создания полей x ,y, width , height  , constraints
        
        //выставляем контейнер по центру экрана в любом случае
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        //сделали ширину с отступами по краям экрана
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        
        //сделали высоту трех полей ввода
        inputsContainerView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        //добавляем поле name в контейнер
        inputsContainerView.addSubview(nameTextField)
        //добавляем сепаратор
        inputsContainerView.addSubview(nameSeparatorView)
        //добавление поля email
        inputsContainerView.addSubview(emailTextField)
        //добавление сепаратора после email
        inputsContainerView.addSubview(emailSeparatorView)
        //добавляем поле password
        inputsContainerView.addSubview(passwordTextField)
        
        //нужные данные для создания полей x ,y, width , height  , constraints
        //распологаем поле в нужном месте относительно контейнера
        // по бокам
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        //сверху
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        //по ширине
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        
        nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
        
        //нужные данные для создания полей x ,y, width , height  , constraints
        
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        
        //нужные данные для создания полей x ,y, width , height  , constraints
        //распологаем поле в нужном месте относительно контейнера
        // по бокам
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        //сверху
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        //по ширине
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        
        emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
        
        //нужные данные для создания полей x ,y, width , height  , constraints
        
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        //нужные данные для создания полей x ,y, width , height  , constraints
        //распологаем поле в нужном месте относительно контейнера
        // по бокам
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        //сверху
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        //по ширине
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        
        passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
        
        
    }
    
    
    func setupLoginRegisterButton(){
        //нужные данные для создания полей x ,y, width , height  , constraints
        
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //topAnchor - верхняя грань кнопки, которую мы распологаем кнопку относительно нижней грани волей ввода(bottomAnchor)
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        
        //ширина кнопки - значение выставляется такое же как и у полей
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        
        //высота кнопки
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    //делает время , батарейку , сеть белым , а не черным 
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
//создаем расширение (шаблон) для всех цветов , чтобы было проще создавать другие цвета
extension UIColor {

    convenience init(r: CGFloat , g: CGFloat , b: CGFloat){
    self.init(red : r/255 , green  : g/255 , blue : b/255 , alpha : 1)
    }

}
