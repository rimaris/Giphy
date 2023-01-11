import Foundation
import UIKit
import Photos

// Presetner (бизнес слой для получения слудеющей гифки)
final class GiphyPresenter: GiphyPresenterProtocol {
    private var giphyFactory: GiphyFactoryProtocol

    // Слой View для общения и отображения случайной гифки
    weak var viewController: GiphyViewControllerProtocol?

    // MARK: - GiphyPresenterProtocol

    init(giphyFactory: GiphyFactoryProtocol = GiphyFactory()) {
        self.giphyFactory = giphyFactory
        self.giphyFactory.delegate = self
    }

    // Загрузка следующей гифки
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
    // Успешная загрузка гифки
    func didRecieveNextGiphy(_ giphy: GiphyModel) {
        // Преобразуем набор картинок в гифку
        let image = UIImage.gif(url: giphy.url)

        DispatchQueue.main.async { [weak self] in
            self?.viewController?.hideHoaler()
            self?.viewController?.showGiphy(image)
        }
    }

    // При загрузке гифки произошла ошибка
    func didReciveError(_ error: GiphyError) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.hideHoaler()
            self?.viewController?.showError()
        }
    }
}
