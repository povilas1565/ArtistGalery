//
//  PhotoGalleryViewController.swift
//  LilPictures
//
//
//

import UIKit

class PhotoGalleryViewController: UIViewController {
    
    
    //MARK: Properties
    
    var viewModel: PhotoGalleryViewModelProtocol! {
        didSet {
            viewModel.fetchImages { [unowned self] in
                loadingIndicator.stopAnimating()
                photoCollectionView.reloadData()
            }
        }
    }
    
    //MARK: - View
    
    var loadingIndicator: UIActivityIndicatorView = LoadingIndicatorView(style: .large)
    
    private lazy var photoCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: PhotoSearchViewController())
        return searchController
    }()
    
    //MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupLoadingIndicator()
        setupPhotoCollectionView()
    }

    override func viewDidLayoutSubviews() {
        loadingIndicator.center = view.center
        photoCollectionView.frame = view.bounds
        view.sendSubviewToBack(photoCollectionView)
    }
    
    //MARK: - Private methods
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
    }
    
    private func setupPhotoCollectionView() {
        view.addSubview(photoCollectionView)
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
    }
    
    private func setupNavigationBar() {
        title = "Gallery"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .label
        
        let refreshButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(refreshButtonTapped(_:))
        )
        
        let favouritesButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(favouritesButtonTapped))
        
        navigationItem.rightBarButtonItems = [refreshButton, favouritesButton]
        
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
    }
    
    //MARK: - Ations
    
    @objc private func refreshButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.fetchImages { [unowned self] in
            sender.isEnabled = false
            photoCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            photoCollectionView.reloadData()
            sender.isEnabled = true
        }
    }
    
    @objc private func favouritesButtonTapped() {
        viewModel.presentFavouritePhotos()
    }

}

//MARK: - UICollectionViewDataSource

extension PhotoGalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfPhotos
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        cell.photoID = viewModel.photoIDForCell(at: indexPath)
        cell.viewModel = self.viewModel.viewModelForCell(at: indexPath)
        return cell
    }
}

//MARK: - UICollectionViewDelegate

extension PhotoGalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.showPhotoDetailsForSelectedCell(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == viewModel.numberOfPhotos - 1 {
            viewModel.fetchAdditionalImages { [unowned self] range in
                let additionalIndexPaths = range.map { IndexPath(item: $0, section: 0) }
                photoCollectionView.insertItems(at: additionalIndexPaths)
            }
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension PhotoGalleryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow = CGFloat(2)
        let paddingWidth = 20 * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingWidth
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem * 1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

//MARK: - UISearchBarDelegate

extension PhotoGalleryViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard
            !searchText.trimmingCharacters(in: .whitespaces).isEmpty,
            searchText.trimmingCharacters(in: .whitespaces).count >= 3
        else { return }
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            self?.viewModel.searchImages(query: searchText) {
                guard let searchResultController = self?.searchController.searchResultsController as? PhotoSearchViewController
                else { return }
                searchResultController.viewModel = self?.viewModel.createPhotoSearchViewModel()
            }
        }
    }
    
    
}
