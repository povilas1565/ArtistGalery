//
//  FavouritePhotoCellViewModel.swift
//  LilPictures
//
//
//

import Foundation

//MARK: - FavouritePhotoCellViewModelProtocol

protocol FavouritePhotoCellViewModelProtocol {
    var imageData: Data? { get }
    func fetchPhoto(completion: @escaping (Data?) -> Void)
}

//MARK: - FavouritePhotoCellViewModel

class FavouritePhotoCellViewModel: FavouritePhotoCellViewModelProtocol {
    var imageData: Data?
    
    private let photo: PhotoStorageModel
    
    init(photo: PhotoStorageModel) {
        self.photo = photo
    }
    
    func fetchPhoto(completion: @escaping (Data?) -> Void) {
        guard let url = photo.previewURL else { return }
        NetworkDataManager.shared.fetchData(from: url) { [weak self] imageData in
            self?.imageData = imageData
            completion(imageData)
        }
    }
    
}
