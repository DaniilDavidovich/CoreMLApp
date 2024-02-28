//
//  ViewController.swift
//  CoreMLApp
//
//  Created by Daniil Davidovich on 27.02.24.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    
    var name: String = ""
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var buttonClassify: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Classify", for: .normal)
        button.addTarget(self, action: #selector(classifyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonGetImage: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Get Image", for: .normal)
        button.addTarget(self, action: #selector(getImageButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "This"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(buttonClassify)
        view.addSubview(buttonGetImage)
        view.addSubview(imageView)
        view.addSubview(label)
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            buttonClassify.widthAnchor.constraint(equalToConstant: 100),
            buttonClassify.heightAnchor.constraint(equalToConstant: 30),
            buttonClassify.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            buttonClassify.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50), // Corrected bottom constraint for buttonClassify
            
            buttonGetImage.widthAnchor.constraint(equalToConstant: 100), // Corrected width anchor for buttonGetImage
            buttonGetImage.heightAnchor.constraint(equalToConstant: 30), // Corrected height anchor for buttonGetImage
            buttonGetImage.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16), // Corrected right anchor for buttonGetImage
            buttonGetImage.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50), // Bottom constraint for buttonGetImage
            
            label.centerXAnchor.constraint(equalTo: buttonClassify.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: buttonClassify.topAnchor, constant: -20),
            
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            imageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16), // Corrected right anchor for imageView
            imageView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -16), // Corrected bottom anchor for imageView
        ])
    }
    
    @objc private func classifyButtonTapped() {
        excecuteRequest(image: imageView.image ?? UIImage())
    }
   
    @objc private func getImageButtonTapped() {
        getimage()
    }
   
    func mlrequest() -> VNCoreMLRequest {
        var myrequest: VNCoreMLRequest?
        
        let modelobj = Inceptionv3()
        do {
            let fruitmodel =
            try VNCoreMLModel(
                for: modelobj.model)
            myrequest = VNCoreMLRequest(model: fruitmodel, completionHandler: {
                (request, error) in self.handleResult(request: request, error: error)
            })
        } catch {
            print("Unable to create a request")
        }
        myrequest!.imageCropAndScaleOption = .centerCrop
        return myrequest!
    }
    func excecuteRequest(image: UIImage) {
        guard
            let ciImage = CIImage(image: image)
        else {
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage)
            do {
                try handler.perform([self.mlrequest()])
            } catch {
                print("Failed to get the description")
            }
        }
    }
    func handleResult(request: VNRequest, error: Error? ) {
        if let classificationresult = request.results as? [VNClassificationObservation] {
            DispatchQueue.main.async {
                self.label.text = classificationresult.first!.identifier
                print(classificationresult.first!.identifier)
            }
        }
        else {
            print("Unable to get the results")
        }
    }
}
extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func getimage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let fimage = info[.editedImage] as!UIImage
        imageView.image = fimage
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

