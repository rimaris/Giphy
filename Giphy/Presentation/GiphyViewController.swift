import UIKit

// Экран на котором показываются гифки
final class GiphyViewController: UIViewController {
    
    @IBOutlet var thumbsDown: UIButton!
    @IBOutlet var thumbsUp: UIButton!
    
    private var gifCounter: Int = 0

    private var likedGifCounter: Int = 0

    @IBOutlet weak var counterLabel: UILabel!

    @IBOutlet weak var giphyImageView: UIImageView!

    @IBOutlet weak var giphyActivityIndicatorView: UIActivityIndicatorView!

    @IBAction func onYesButtonTapped() {
        highlightImageBorder(true)
        presenter.saveGif(giphyImageView.image)
        likedGifCounter += 1
        anyButtonTapped()
    }

    @IBAction func onNoButtonTapped() {
        highlightImageBorder(false)
        anyButtonTapped()
    }

    // Слой Presenter - бизнес логика приложения, к которым должен общаться UIViewController
    private lazy var presenter: GiphyPresenterProtocol = {
        let presenter = GiphyPresenter()
        presenter.viewController = self
        return presenter
    }()

    // MARK: - Жизенный цикл экрана

    override func viewDidLoad() {
        super.viewDidLoad()
        makeButtonRounded(button: thumbsUp)
        makeButtonRounded(button: thumbsDown)
        restart()
    }
    
    private func makeButtonRounded(button: UIButton) {
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
    }
    
    
    private func anyButtonTapped() {
        updateCounterLabel()
        if gifCounter >= 10 {
            showEndOfGiphy()
            return
        }
        presenter.fetchNextGiphy()
    }
}

// MARK: - Приватные методы

private extension GiphyViewController {
    func updateCounterLabel() {
        gifCounter += 1
        if gifCounter < 10 {
            counterLabel.text = "\(gifCounter + 1)/10"
        }
    }

    func restart() {
        likedGifCounter = 0
        gifCounter = 0
        counterLabel.text = "1/10"
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
        let alert = UIAlertController(title: "Мемы закончились!", message: "Вам понравилось: \(likedGifCounter)/10", preferredStyle: .alert)
        let action = UIAlertAction(title: "Хочу посмотреть еще гифок", style: .default) { [weak self] _ in
            self?.restart()
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

    func showGiphy(_ image: UIImage?) {
        disableImageBorder()
        giphyImageView.image = image
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
    
    func highlightImageBorder(_ isGreen: Bool) {
        giphyImageView.layer.masksToBounds = true
        giphyImageView.layer.borderWidth = 8
        if isGreen {
            giphyImageView.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            giphyImageView.layer.borderColor = UIColor.ypRed.cgColor
        }

    }
    
    func disableImageBorder() {
        giphyImageView.layer.borderWidth = 0
    }
}


