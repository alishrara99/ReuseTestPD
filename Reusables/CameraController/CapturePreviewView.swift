//
//  CapturePreviewView.swift
//  MyMonty
//
//  Created by Ali admin on 13/02/2023.
//

import UIKit

class CapturePreviewView: UIView {
    
    private var onConfirmCapture: ((UIImage)->())?
    private weak var cameraController: CameraController?
    
    let photoImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy private var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
//    lazy private var retryPhotoButton: SecondaryButton = {
//        let button = SecondaryButton()
//        button.title = "Take another one"
//        button.addTarget(self, action: #selector(handleRetryCapture), for: .touchUpInside)
//        return button
//    }()
    
//    lazy private var confirmPhotoButton: PrimaryButton = {
//        let button = PrimaryButton()
//        button.title = "Use this photo"
//        button.addTarget(self, action: #selector(handleConfirmPhoto), for: .touchUpInside)
//        return button
//    }()
    
    init(cameraController: CameraController,
         frame: CGRect,
         onConfirmCapture: ((UIImage)->())?) {
        super.init(frame: frame)
        
        self.cameraController = cameraController
        self.onConfirmCapture = onConfirmCapture
        
//        addSubviews(photoImageView, cancelButton, retryPhotoButton, confirmPhotoButton)
        
//        photoImageView.setViewConstraints(top: topAnchor,
//                                          left: leftAnchor,
//                                          right: rightAnchor,
//                                          bottom: bottomAnchor)
//
//        cancelButton.setViewConstraints(top: safeAreaLayoutGuide.topAnchor,
//                                        left: leftAnchor,
//                                        topMargin: 16,
//                                        leftMargin: 16,
//                                        width: 50,
//                                        height: 50)
        
//        retryPhotoButton.setViewConstraints(left: leftAnchor,
//                                            right: rightAnchor,
//                                            bottom: bottomAnchor,
//                                            leftMargin: 16,
//                                            rightMargin: 16,
//                                            bottomMargin: 32)
//        retryPhotoButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//        
//        confirmPhotoButton.setViewConstraints(left: leftAnchor,
//                                              right: rightAnchor,
//                                              bottom: retryPhotoButton.topAnchor,
//                                              leftMargin: 16,
//                                              rightMargin: 16,
//                                              bottomMargin: 8)
//        confirmPhotoButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func dismissCameraController() {
        cameraController?.dismiss(animated: true)
    }
    
    @objc private func handleCancel() {
        DispatchQueue.main.async { [weak self] in
            guard let self else {return}
            self.dismissCameraController()
        }
    }
    
    @objc private func handleRetryCapture() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.cameraController?.captureSession.startRunning()
            self.removeFromSuperview()
        }
    }
    
    @objc private func handleConfirmPhoto() {
        guard let previewImage = photoImageView.image else { return }
        
        onConfirmCapture?(previewImage)
        dismissCameraController()
    }
}

