import Foundation
import UIKit
import Photos

final class GiphyPresenter: GiphyPresenterProtocol {
    private var giphyFactory: GiphyFactoryProtocol

    weak var viewController: GiphyViewControllerProtocol?

    // MARK: - GiphyPresenterProtocol

    init(giphyFactory: GiphyFactoryProtocol = GiphyFactory()) {
        self.giphyFactory = giphyFactory
        self.giphyFactory.delegate = self
    }

    func fetchNextGiphy() {
        viewController?.showLoader()
        
        giphyFactory.requestNextGiphy()
    }

    func saveGif(_ image: UIImage?) {
        guard let data = image?.pngData() else {
            return
        }

        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo, data: data, options: nil)
        })
    }
}

// MARK: - GiphyFactoryDelegate

extension GiphyPresenter: GiphyFactoryDelegate {
    
    func didRecieveNextGiphy(_ giphy: GiphyModel) {
        
        let image = UIImage.gif(url: giphy.url)

        DispatchQueue.main.async { [weak self] in
            self?.viewController?.hideHoaler()
            self?.viewController?.showGiphy(image)
        }
    }

    func didReciveError(_ error: GiphyError) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.hideHoaler()
            self?.viewController?.showError()
        }
    }
}
