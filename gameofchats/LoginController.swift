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
    
    var messages: MessagesController?

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
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        
        return button
    }()
    //определяет в какой вкладке мы назодимся 
    @objc func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
        handleLogin()
        }else{
        handleRegister()
        }
    }
    
    func handleLogin () {
        
        guard let email = emailTextField.text , let password = passwordTextField.text  else {
            print("Form is not valid")
            return
        }
    
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
        
        if  error != nil {
        print(error!)
            return
        }
        
        self.messages?.fetchUserAndSetupNavBarTitle()
            
        //отрабатывает , когда успешно вошел пользователь
        self.dismiss(animated: true, completion: nil)
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
    lazy var profileImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "stark")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        //для возможности выбора размера картинки для аватарки
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    

    //создание вскладок login/register
    lazy var loginRegisterSegmentedControl : UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login" , "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    
    }()
    
    @objc func handleLoginRegisterChange () {
        //меняет название кнопки в соответствии с выбранной вкладкой
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        //изменение контейнера для полей ввода
        inputsContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        //изменение высоты поля name в вкладке Login 
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        //пришлось вручную убирать placeholder , потому что когда делаем строку = 0 placeholder наполовину вылазит сверху
        nameTextField.placeholder = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? "" : "Name"

        nameTextFieldHeightAnchor?.isActive = true
        
        //изменение высоты поля email в вкладке Login при переходах между вкладками
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        //изменение высоты поля password в вкладке Login при переходах между вкладками
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //цвет бекграунда логин контроллера
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)
        view.addSubview(loginRegisterSegmentedControl)
        
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupProfileImageView()
        setupLoginRegisterSegmentedControl()
        
        
    }
    
    
    func setupLoginRegisterSegmentedControl() {
    //нужные данные для создания полей x ,y, width , height  , constraints
        
        //выставляем по центру
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //привязываем по высоте
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor , multiplier : 1).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
    }
    
    func setupProfileImageView () {
        
        //нужные данные для создания полей x ,y, width , height  , constraints
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //картинка ставится всегда выше чем лог/рег
        profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -12).isActive = true
        
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        
    }
    
    var inputsContainerViewHeightAnchor : NSLayoutConstraint?
    var nameTextFieldHeightAnchor : NSLayoutConstraint?
    var emailTextFieldHeightAnchor : NSLayoutConstraint?
    var passwordTextFieldHeightAnchor : NSLayoutConstraint?
    
    func setupInputsContainerView(){
        //нужные данные для создания полей x ,y, width , height  , constraints
        
        //выставляем контейнер по центру экрана в любом случае
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        //сделали ширину с отступами по краям экрана
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        
        //сделали высоту трех полей ввода
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
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
        //сделали контроль над отображением поля ввода name
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        
        
        
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
        
        
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        
        emailTextFieldHeightAnchor?.isActive = true
        
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
        
        
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        
        passwordTextFieldHeightAnchor?.isActive = true
        
        
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
