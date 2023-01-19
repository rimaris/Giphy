import UIKit

final class GiphyViewController: UIViewController {
    
    @IBOutlet var thumbsDown: UIButton!
    @IBOutlet var thumbsUp: UIButton!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var giphyImageView: UIImageView!
    @IBOutlet weak var giphyActivityIndicatorView: UIActivityIndicatorView!
    
    private var gifCounter: Int = 0
    private var likedGifCounter: Int = 0
    
    private lazy var presenter: GiphyPresenterProtocol = {
        let presenter = GiphyPresenter()
        presenter.viewController = self
        return presenter
    }()
    
    private let maxGifCount = 10
    
    // MARK: - Actions
    
    @IBAction func onYesButtonTapped() {
        presenter.saveGif(giphyImageView.image)
        likedGifCounter += 1
        anyButtonTapped(isYes: true)
    }
    
    @IBAction func onNoButtonTapped() {
        anyButtonTapped(isYes: false)
    }
    
    // MARK: - Жизенный цикл экрана
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeButtonRounded(button: thumbsUp)
        makeButtonRounded(button: thumbsDown)
        disableButtons()
        restart()
    }
    
    private func makeButtonRounded(button: UIButton) {
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
    }
    
    private func anyButtonTapped(isYes: Bool) {
        disableButtons()
        highlightImageBorder(isYes: isYes)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.disableImageBorder()
            
            self.updateCounterLabel()
            if self.gifCounter >= self.maxGifCount {
                self.showEndOfGiphy()
                return
            }
            self.presenter.fetchNextGiphy()
        }
    }
}

// MARK: - Приватные методы

private extension GiphyViewController {
    func updateCounterLabel() {
        gifCounter += 1
        if gifCounter < maxGifCount {
            counterLabel.text = "\(gifCounter + 1)/\(maxGifCount)"
        }
    }
    
    func restart() {
        likedGifCounter = 0
        gifCounter = 0
        counterLabel.text = "1/\(maxGifCount)"
        presenter.fetchNextGiphy()
    }
}

// MARK: - GiphyViewControllerProtocol

extension GiphyViewController: GiphyViewControllerProtocol {
    
    func showError() {
        let alert = UIAlertController(title: "Что-то пошло не так(", message: "Невозможно загрузить данные", preferredStyle: .alert)
        let action = UIAlertAction(title: "Попробовать еще раз", style: .default) { [weak self] _ in
            self?.presenter.fetchNextGiphy()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showEndOfGiphy() {
        let alert = UIAlertController(title: "Мемы закончились!", message: "Вам понравилось: \(likedGifCounter)/\(maxGifCount)", preferredStyle: .alert)
        let action = UIAlertAction(title: "Хочу посмотреть еще гифок", style: .default) { [weak self] _ in
            self?.restart()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showGiphy(_ image: UIImage?) {
        giphyImageView.image = image
        enableButtons()
    }
    
    func showLoader() {
        giphyActivityIndicatorView.isHidden = false
        giphyImageView.image = nil
        giphyActivityIndicatorView.startAnimating()
    }
    
    func hideHoaler() {
        giphyActivityIndicatorView.stopAnimating()
        giphyActivityIndicatorView.isHidden = true
    }
    
    private func highlightImageBorder(isYes: Bool) {
        giphyImageView.layer.masksToBounds = true
        giphyImageView.layer.borderWidth = 8
        giphyImageView.layer.borderColor = isYes ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    private func disableImageBorder() {
        giphyImageView.layer.borderWidth = 0
    }
    
    private func disableButtons() {
        thumbsUp.isEnabled = false
        thumbsDown.isEnabled = false
    }
    
    private func enableButtons() {
        thumbsUp.isEnabled = true
        thumbsDown.isEnabled = true
    }
}
