//
//  PlataformaViewController.swift
//  MyGames
//
//  Created by Thiago Matheus on 27/05/20.
//  Copyright © 2020 Douglas Frari. All rights reserved.
//

import UIKit
import Photos

class PlataformaViewController: UIViewController {

    @IBOutlet weak var tvPlataformName: UITextField!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var btAddLogo: UIButton!
    @IBOutlet weak var btSave: UIButton!
    
    var console: Console?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        prepareDataLayout()
    }
    
    func prepareDataLayout() {
        if console != nil {
            title = "Editar jogo"
            btSave.setTitle("ALTERAR", for: .normal)
            tvPlataformName.text = console?.name

            imgLogo.image = console?.cover as? UIImage
            
            if console?.cover != nil {
                btAddLogo.setTitle(nil, for: .normal)
            }
        }

        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        toolbar.tintColor = UIColor(named: "main")
        let btFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        // tip. faz o text field exibir os dados predefinidos pela picker view
        //tfConsole.inputView = pickerView
        //tfConsole.inputAccessoryView = toolbar
    }
    
    @IBAction func selectImage(_ sender: UIButton) {
        // para adicionar uma imagem da biblioteca
            print("AddEditCover")
            
            
            // para adicionar uma imagem da biblioteca
        
            
            let alert = UIAlertController(title: "Selecinar capa", message: "De onde você quer escolher a capa?", preferredStyle: .actionSheet)
            
            let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default, handler: {(action: UIAlertAction) in
                self.selectPicture(sourceType: .photoLibrary)
            })
            alert.addAction(libraryAction)
            
            let photosAction = UIAlertAction(title: "Album de fotos", style: .default, handler: {(action: UIAlertAction) in
                self.selectPicture(sourceType: .savedPhotosAlbum)
            })
            alert.addAction(photosAction)
            
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
    }
    
    func selectPicture(sourceType: UIImagePickerController.SourceType) {
        
        //Photos
        let photos = PHPhotoLibrary.authorizationStatus()
        
        if photos == .denied {
            // TODO considetar exibir um dialogo pedindo para o usuario ir em configuracoes
            print(".denied")
            
        } else if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    
                    self.chooseImageFromLibrary(sourceType: sourceType)
                    
                } else {
                    // TODO considetar exibir um dialogo pedindo para o usuario ir em configuracoes
                    print("unauthorized -- TODO message")
                }
            })
        } else if photos == .authorized {
            
            self.chooseImageFromLibrary(sourceType: sourceType)
        }
    }
    
    func chooseImageFromLibrary(sourceType: UIImagePickerController.SourceType) {
        
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.navigationBar.tintColor = UIColor(named: "main")
            
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }

    
    @IBAction func save(_ sender: Any) {
        if console == nil {
            // context está sendo obtida pela extension 'ViewController+CoreData'
            console = Console(context: context)
        }
        
        console?.name = tvPlataformName.text
        console?.cover = imgLogo.image
        
        do {
            try self.context.save()
        } catch {
            print(error.localizedDescription)
        }
        
        navigationController?.popViewController(animated: true)

    }
}

extension PlataformaViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            // ImageView won't update with new image
            // bug fixed: https://stackoverflow.com/questions/42703795/imageview-wont-update-with-new-image
            DispatchQueue.main.async {
                self.imgLogo.image = pickedImage
                self.imgLogo.setNeedsDisplay() // fixed here
                self.btAddLogo.setTitle(nil, for: .normal)
                self.btAddLogo.setNeedsDisplay()
            }
        }
        
        dismiss(animated: true, completion: nil)
        
    }
}
