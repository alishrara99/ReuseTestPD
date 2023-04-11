//
//  CameraController.swift
//  MyMonty
//
//  Created by Ali admin on 13/02/2023.
//

import UIKit
import AVFoundation

class CameraController: UIViewController {
    
    enum OperationType {
        case photoCapture
        case qrCodeScan
    }
    
    var captureSession = AVCaptureSession()
    private var previewLayer = AVCaptureVideoPreviewLayer()
    
    private var onConfirmCapture: ((UIImage)->())?
    private var onQrCodeFound: ((String)->())?
    private var operationType: OperationType?
    
    init(photoCapture onConfirmCapture: @escaping (UIImage)->()) {
        super.init(nibName: nil, bundle: nil)
        self.onConfirmCapture = onConfirmCapture
        self.operationType = .photoCapture
        commonInit()
    }
    
    init(qrCodeScan onQrCodeFound: @escaping (String)->()) {
        super.init(nibName: nil, bundle: nil)
        self.onQrCodeFound = onQrCodeFound
        self.operationType = .qrCodeScan
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func commonInit() {
        modalPresentationStyle = .fullScreen
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - Variables
    lazy private var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    lazy private var takePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(.capturePhoto?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleTakePhoto), for: .touchUpInside)
        return button
    }()
    
    lazy private var qrScanBorder: UIView = {
        let qrScanBorder = UIView()
        qrScanBorder.layer.borderWidth = 2
        qrScanBorder.layer.borderColor = UIColor.red.cgColor
        return qrScanBorder
    }()
    
    private let photoOutput = AVCapturePhotoOutput()
    private let metadataOutput = AVCaptureMetadataOutput()
    
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        openCamera()
    }
    
    
    // MARK: - Private Methods
    private func setupUI() {
        
        view.addSubview(backButton)
        backButton.setViewConstraints(top: view.safeAreaLayoutGuide.topAnchor,
                                      left: view.leftAnchor,
                                      topMargin: 16,
                                      leftMargin: 16,
                                      width: 50,
                                      height: 50)
        
        switch operationType {
        case .photoCapture:
            view.addSubview(takePhotoButton)
            takePhotoButton.setViewConstraints(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                            bottomMargin: 64,
                                            width: 80,
                                            height: 80)
            takePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        case .qrCodeScan:
            view.addSubview(qrScanBorder)
            qrScanBorder.setViewConstraints(width: 200,
                                            height: 200)
            qrScanBorder.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            qrScanBorder.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        case .none:
            break
        }
        view.layoutIfNeeded()
    }
    
    private func openCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.setupCaptureSession()
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                    }
                } else {
                    self.handleDismiss()
                }
            }
            
        default:
            self.handleDismiss()
        }
    }
    
    private func setupCaptureSession() {
        setupUI()
        switch operationType {
        case .photoCapture:
            if let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                addCaptureDeviceInput(captureDevice: captureDevice)
                addCaptureDeviceOutput(captureOutput: photoOutput)
                setPreviewLayerAndRunSession()
            }
        case .qrCodeScan:
            if let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                addCaptureDeviceInput(captureDevice: captureDevice)
                addCaptureDeviceOutput(captureOutput: metadataOutput)
                setPreviewLayerAndRunSession()
                setMetadataOutputConfig()
            }
        case .none:
            break
        }
    }
    
    private func addCaptureDeviceInput(captureDevice: AVCaptureDevice) {
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch let error {
            print("Failed to set input device with error: \(error)")
        }
    }
    
    private func addCaptureDeviceOutput(captureOutput: AVCaptureOutput) {
        if captureSession.canAddOutput(captureOutput) {
            captureSession.addOutput(captureOutput)
        }
    }
    
    private func setPreviewLayerAndRunSession() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = self.view.frame
        previewLayer.videoGravity = .resizeAspectFill
        self.view.layer.insertSublayer(previewLayer, at: 0)
        
        captureSession.commitConfiguration()
//        DispatchQueue.global(qos: .userInteractive).async {
            self.captureSession.startRunning()
//        }
    }
    
    /// should be called after running the capture session
    private func setMetadataOutputConfig() {
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
        metadataOutput.rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: qrScanBorder.frame)
    }
    
    @objc private func handleDismiss() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func handleTakePhoto() {
        let photoSettings = AVCapturePhotoSettings()
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let cgImage = UIImage(data: imageData)?.cgImage else { return }
        captureSession.stopRunning()
        let previewImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .leftMirrored)
        
        
        let photoPreviewContainer = CapturePreviewView(cameraController: self,
                                                       frame: view.frame,
                                                       onConfirmCapture: onConfirmCapture)
        
        photoPreviewContainer.photoImageView.image = previewImage
        self.view.addSubviews(photoPreviewContainer)
    }
}

extension CameraController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            captureSession.stopRunning()
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            onQrCodeFound?(stringValue)
        }
        dismiss(animated: true)
    }
}
