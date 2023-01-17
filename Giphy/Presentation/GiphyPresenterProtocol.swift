import UIKit

protocol GiphyPresenterProtocol: AnyObject {
    init(giphyFactory: GiphyFactoryProtocol)
    
    func fetchNextGiphy()
    func saveGif(_ image: UIImage?)
}
