import UIKit

protocol FeedPostCellDelegate: AnyObject {
    func feedPostCell(_ cell: FeedPostCell, didTapUserWithId id: Int)
    func feedPostCell(_ cell: FeedPostCell, didTapPeak peak: Peak)
}

class FeedPostCell : UITableViewCell {
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postDescriptionLabel: UILabel!
    @IBOutlet weak var postUserAvatar: UIImageView!
    @IBOutlet weak var postUserButton: UIButton!
    @IBOutlet weak var postPeakButton: UIButton!
    
    @IBOutlet weak var postWeatherIcon: UIImageView!
    @IBOutlet weak var postWeatherLabel: UILabel!
    
    private var userId: Int?
    private var peak: Peak?
    weak var delegate: FeedPostCellDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        postImageView.layer.cornerRadius = 10
    }
    
    func configure(with post: Post) {
        postTitleLabel.text = post.name
        postDescriptionLabel.text = post.description
        if let peak = post.peak {
            let dateStr = ISO8601DateFormatter().date(from: post.created_at)?.formatted() ?? ""
            let peakName = "\(peak.name), \(peak.altitude) m.n.v. \(dateStr)"
            postPeakButton.setTitle(peakName, for: .normal)
        }
        postImageView.loadFrom(URLAddress: "\(APIURL)/\(post.photo_path)")
        postUserButton.setTitle(post.user?.name, for: .normal)
        if let posterPfpUri = post.user?.photo_uri {
            postUserAvatar.loadFrom(url: "\(APIURL)/\(posterPfpUri)")
            postUserAvatar.contentMode = .scaleAspectFill
            postUserAvatar.clipsToBounds = true
            postUserAvatar.layer.cornerRadius = postUserAvatar.frame.height / 2
            postUserAvatar.layer.masksToBounds = true
        }
        userId = post.user_id
        peak = post.peak
        loadWeatherData(for: post)
    }
    
    private func loadWeatherData(for post: Post) {
        guard let weather = post.weather else {
            postWeatherIcon.isHidden = true
            postWeatherLabel.isHidden = true
            return
        }

        let parts = weather.components(separatedBy: ";")
        if parts.count < 3 { return }

        let description = parts[0]
        let temperature = parts[1]
        let iconURL = parts[2]
        postWeatherLabel.text = "\(description), \(temperature)°C"
        postWeatherIcon.loadFrom(url: iconURL)
    }

    @IBAction private func userTapped() {
        guard let userId = self.userId else { return }
        delegate?.feedPostCell(self, didTapUserWithId: userId)
    }
    
    @IBAction func peakTapped() {
        guard let peak = self.peak else { return }
        delegate?.feedPostCell(self, didTapPeak: peak)
    }
}
