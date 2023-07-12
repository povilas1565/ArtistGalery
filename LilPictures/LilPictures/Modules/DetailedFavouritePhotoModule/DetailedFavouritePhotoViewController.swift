//
//  DetailedFavouritePhotoViewController.swift
//  LilPictures
//
//
//

import UIKit

class DetailedFavouritePhotoViewController: UIViewController {
    
    //MARK: Properties
    
    var viewModel: DetailedFavouritePhotoViewModelProtocol! {
        didSet {
            viewModel.fetchPhoto { [weak self] imageData in
                guard let imageData = imageData else { return }
                self?.loadingIndicator.stopAnimating()
                self?.photoImageView.image = UIImage(data: imageData)
            }
        }
    }
    
    //MARK: - View
    private lazy var loadingIndicator = UIActivityIndicatorView(style: .large)
    
    private let buttonSymbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
    
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var saveButton: UIButton = {
        let button = createPhotoActionButton(
            imageName: "square.and.arrow.down",
            foregroundColor: .white,
            backgroundColor: .systemIndigo
        )
        button.addTarget(self, action: #selector(saveButtonTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var moreButton: UIButton = {
        let button = createPhotoActionButton(
            imageName: "ellipsis",
            foregroundColor: .white,
            backgroundColor: .lightGray
        )
        button.addTarget(self, action: #selector(moreButtonTapped(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        navigationItem.largeTitleDisplayMode = .never
        setupLoadingIndicator()
        setConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        loadingIndicator.center = photoImageView.center
        saveButton.layer.cornerRadius = saveButton.frame.height / 2
        moreButton.layer.cornerRadius = moreButton.frame.height / 2
    }

    //MARK: - Ations
    
    @objc private func saveButtonTapped(_ sender: UIButton) {
        guard
            sender == saveButton,
            let image = photoImageView.image
        else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func moreButtonTapped(_ sender: UIButton) {
        guard
            sender == moreButton,
            let image = photoImageView.image
        else { return }
        let share = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(share, animated: true)
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlert(title: "Saving error", message: error.localizedDescription)
        } else {
            showAlert(title: "Successfully", message: "The image has been saved")
        }
    }
    
    //MARK: - Private methods
    
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    private func createPhotoActionButton(imageName: String, foregroundColor: UIColor, backgroundColor: UIColor) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: imageName, withConfiguration: buttonSymbolConfig), for: .normal)
        button.backgroundColor = backgroundColor
        button.tintColor = foregroundColor
        return button
    }

    private func setConstraints() {
       photoActionButtonsConstraints()
        
        view.addSubview(photoImageView)
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            photoImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            photoImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            photoImageView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -20)
        ])
    }
    
    private func photoActionButtonsConstraints() {
        let buttonSize = CGFloat(45)
        
        view.addSubview(saveButton)
        let saveButtonConstraints = [
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -40),
            saveButton.heightAnchor.constraint(equalToConstant: buttonSize),
            saveButton.widthAnchor.constraint(equalToConstant: buttonSize)
        ]
        
        view.addSubview(moreButton)
        let moreButtonConstraints = [
            moreButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 40),
            moreButton.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor),
            moreButton.heightAnchor.constraint(equalToConstant: buttonSize),
            moreButton.widthAnchor.constraint(equalToConstant: buttonSize)
        ]
        
        NSLayoutConstraint.activate(saveButtonConstraints)
        NSLayoutConstraint.activate(moreButtonConstraints)
    }
}
