//
//  HomeViewController.swift
//  Journey
//
//  Created by 초이 on 2021/06/29.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - @IBOutlet Properties
    
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var courseTitleButton: UIButton!
    @IBOutlet weak var courseDayBoxView: UIView!
    @IBOutlet weak var courseDayLabel: UILabel!
    @IBOutlet weak var densityProgressView: UIProgressView!
    @IBOutlet weak var percentDescriptionButton: UIButton!
    @IBOutlet weak var firstIndicatiorLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var thirdIndicatorLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var densityPercentLabel: UILabel!
    @IBOutlet weak var journeyImageView: UIImageView!
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = CGPoint(x: self.view.center.x, y: self.view.center.y - self.topbarHeight)
        activityIndicator.hidesWhenStopped = false
        activityIndicator.style = UIActivityIndicatorView.Style.medium
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    var backgroundView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getHomeInfo()
        initNavigationBar()
        initAttributes()
        setIndicatorPosition()
    }
    
    // MARK: - @IBAction Functions
    
    @objc func touchAwardButton(sender: UIButton) {
        let medalStoryboard = UIStoryboard(name: Const.Storyboard.Name.medal, bundle: nil)
        guard let medalViewController = medalStoryboard.instantiateViewController(withIdentifier: Const.ViewController.Identifier.medal) as? MedalViewController else {
            return
        }
        self.navigationController?.pushViewController(medalViewController, animated: true)
    }
    
    @objc func touchSettingButton(sender: UIButton) {
        
    }
    
    // MARK: - Functions
    
    private func initNavigationBar() {
        let awardItem = initNavigationIconWithSpacing(image: Const.Image.medalIcon, buttonEvent: #selector(touchAwardButton(sender:)))
        let settingItem = initNavigationIconWithSpacing(image: Const.Image.settingIcon, buttonEvent: #selector(touchSettingButton(sender:)))
        
        self.navigationItem.rightBarButtonItems = [settingItem, awardItem]
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.initNavigationBarWithoutBackButton(navigationItem: self.navigationItem)
    }
    
    private func initNavigationIconWithSpacing(image: UIImage, buttonEvent: Selector) -> UIBarButtonItem {
        let button: UIButton = UIButton.init(type: .custom)
        button.setImage(image, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
        button.addTarget(self, action: buttonEvent, for: .touchUpInside)
        
        let item = UIBarButtonItem(customView: button)
        let currWidth = item.customView?.widthAnchor.constraint(equalToConstant: 40)
        currWidth?.isActive = true
        let currHeight = item.customView?.heightAnchor.constraint(equalToConstant: 40)
        currHeight?.isActive = true
        
        return item
    }
    
    private func initAttributes() {
        courseDayBoxView.layer.cornerRadius = 16
        courseDayBoxView.clipsToBounds = true
        
        percentDescriptionButton.layer.cornerRadius = percentDescriptionButton.frame.width / 2
        
        courseTitleButton.contentEdgeInsets = UIEdgeInsets(top: 0.01, left: 0, bottom: 0.01, right: 0)
    }
    
    private func initProgressView(densityPercent: CGFloat) {
        let indicatorWidth = 8 / (UIScreen.main.bounds.width - 48)
        densityProgressView.makeRounded(radius: 7)
        densityProgressView.layer.sublayers![1].cornerRadius = 7
        densityProgressView.subviews[1].clipsToBounds = true
        densityProgressView.progress = Float((densityPercent / 100) + indicatorWidth)
    }
    
    private func setDensityPercent(densityPercent: CGFloat) {
        densityPercentLabel.text = "\(Int(densityPercent))%"
        initProgressView(densityPercent: densityPercent)
    }
    
    private func updateData(data: HomeData) {
        setMainJourneyImage(affinity: data.affinity)
        setMainTitleTextButton(situation: data.situation, courseTitle: data.course.title)
        setCourseDayLabel(situation: data.situation, challenges: data.course.challenges)
        setDensityPercent(densityPercent: CGFloat(data.affinity))
        self.detachActivityIndicator()
    }
    
    private func setMainJourneyImage(affinity: Int) {
        switch affinity {
        case 0...25:
            journeyImageView.image = Const.Image.level1Journey
        case 26...50:
            journeyImageView.image = Const.Image.level2Journey
        case 51...75:
            journeyImageView.image = Const.Image.level3Journey
        case 76...100:
            journeyImageView.image = Const.Image.level4Journey
        default:
            break
        }
    }
    
    private func setMainTitleTextButton(situation: Int, courseTitle: String) {
        // 0: 코스 시작 전, 1: 코스 진행 중
        if situation == 0 {
            courseTitleButton.setTitle("나와 함께해보겠어?", for: .normal)
            courseTitleButton.isEnabled = false
        } else {
            courseTitleButton.setTitle(courseTitle, for: .normal)
            courseTitleButton.isEnabled = true
        }
    }
    
    private func setCourseDayLabel(situation: Int, challenges: [Challenge]) {
        if situation == 0 {
            courseDayBoxView.isHidden = true
        } else {
            courseDayBoxView.isHidden = false
            courseDayLabel.text = "\(findCurrentChallengesDay(challenges: challenges)) 일차"
        }
    }
    
    private func findCurrentChallengesDay(challenges: [Challenge]) -> Int {
        var day = 0
        for challenges in challenges {
            if challenges.situation == 0 {
                return day
            }
            day += 1
        }
        return day
    }
    
    private func setIndicatorPosition() {
        let progressViewWidth = (UIScreen.main.bounds.width - 48)
        firstIndicatiorLeadingConstraint.constant = progressViewWidth / 4
        thirdIndicatorLeadingConstraint.constant = progressViewWidth * 3 / 4
    }
    
    private func attachActivityIndicator() {
        backgroundView.backgroundColor = UIColor.white
        self.view.addSubview(backgroundView)
        self.view.addSubview(self.activityIndicator)
    }
    
    private func detachActivityIndicator() {
        if self.activityIndicator.isAnimating {
            self.activityIndicator.stopAnimating()
        }
        self.backgroundView.removeFromSuperview()
        self.activityIndicator.removeFromSuperview()
    }
}

extension HomeViewController {
    
    func getHomeInfo() {
        self.attachActivityIndicator()
        HomeAPI.shared.getHomeInfo { (response) in
            switch response {
            case .success(let home):
                if let data = home as? HomeData {
                    self.updateData(data: data)
                }

            case .requestErr(let message):
                print("requestErr", message)
            case .pathErr:
                print(".pathErr")
            case .serverErr:
                print("serverErr")
            case .networkFail:
                print("networkFail")
            }
        }
    }
    
}
