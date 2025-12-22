//
//  EZSwipeTabController.swift
//  Planinski dnevnik
//
//

import UIKit

// MARK: - Tab Item Configuration
public struct EZSwipeTabItem {
    public let icon: UIImage
    public let selectedIcon: UIImage
    public let title: String?
    
    public init(systemIconName: String, title: String? = nil) {
        self.icon = UIImage(systemName: systemIconName) ?? UIImage()
        self.selectedIcon = UIImage(systemName: systemIconName) ?? UIImage()
        self.title = title
    }

    public init(icon: UIImage, selectedIcon: UIImage, title: String? = nil) {
        self.icon = icon
        self.selectedIcon = selectedIcon
        self.title = title
    }
}

// MARK: - Data Source Protocol
public protocol EZSwipeTabControllerDataSource: AnyObject {
    func viewControllerData() -> [UIViewController]
    func tabItemsData() -> [EZSwipeTabItem]
    func indexOfStartingPage() -> Int
    //@objc optional func changedToPageIndex(_ index: Int)
}

// MARK: - Tab Bar View
public class EZSwipeTabBar: UIView {

    private var tabButtons: [UIButton] = []
    private var tabItems: [EZSwipeTabItem] = []
    private var selectedIndex: Int = 0

    var onTabSelected: ((Int) -> Void)?

    // Customization properties
    public var barBackgroundColor: UIColor = UIColor(named: "Page Background")! {
        didSet { backgroundColor = barBackgroundColor }
    }
    public var selectedTintColor: UIColor = UIColor(named: "AccentColor")!
    public var unselectedTintColor: UIColor = .systemGray
    public var showTopBorder: Bool = true {
        didSet { topBorderView.isHidden = !showTopBorder }
    }
    public var topBorderColor: UIColor = .separator {
        didSet { topBorderView.backgroundColor = topBorderColor }
    }

    private let topBorderView = UIView()
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = barBackgroundColor

        // Top border
        topBorderView.backgroundColor = topBorderColor
        topBorderView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topBorderView)

        // Stack view for buttons
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            topBorderView.topAnchor.constraint(equalTo: topAnchor),
            topBorderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topBorderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topBorderView.heightAnchor.constraint(equalToConstant: 0.5),

            stackView.topAnchor.constraint(equalTo: topBorderView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func configure(with items: [EZSwipeTabItem], selectedIndex: Int = 0) {
        self.tabItems = items
        self.selectedIndex = selectedIndex

        // Clear existing buttons
        tabButtons.forEach { $0.removeFromSuperview() }
        tabButtons.removeAll()

        // Create new buttons
        for (index, item) in items.enumerated() {
            let button = createTabButton(for: item, at: index)
            tabButtons.append(button)
            stackView.addArrangedSubview(button)
        }

        updateSelection(animated: false)
    }

    private func createTabButton(for item: EZSwipeTabItem, at index: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.tag = index
        button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)

        // Configure button based on whether it has a title
        if let title = item.title {
            var config = UIButton.Configuration.plain()
            config.image = item.icon
            config.title = title
            config.imagePlacement = .top
            config.imagePadding = 4
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
                var attributes = attributes
                attributes.font = UIFont(name: "Outfit", size: 13)!
                //attributes.font = UIFont.systemFont(ofSize: 10, weight: .medium)
                return attributes
            }
            button.configuration = config
        } else {
            button.setImage(item.icon, for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
        }

        button.tintColor = unselectedTintColor

        return button
    }

    @objc private func tabButtonTapped(_ sender: UIButton) {
        let newIndex = sender.tag
        guard newIndex != selectedIndex else { return }
        onTabSelected?(newIndex)
    }

    func setSelectedIndex(_ index: Int, animated: Bool = true) {
        guard index >= 0 && index < tabButtons.count else { return }
        selectedIndex = index
        updateSelection(animated: animated)
    }

    private func updateSelection(animated: Bool) {
        let duration = animated ? 0.2 : 0.0

        UIView.animate(withDuration: duration) {
            for (index, button) in self.tabButtons.enumerated() {
                let isSelected = index == self.selectedIndex
                let item = self.tabItems[index]

                if let _ = item.title {
                    button.configuration?.image = isSelected ? item.selectedIcon : item.icon
                } else {
                    button.setImage(isSelected ? item.selectedIcon : item.icon, for: .normal)
                }

                button.tintColor = isSelected ? self.selectedTintColor : self.unselectedTintColor
            }
        }
    }
}

// MARK: - Main Controller
open class EZSwipeTabController: UIViewController {

    // MARK: - Public Properties
    open weak var datasource: EZSwipeTabControllerDataSource?

    public var stackVC: [UIViewController]!
    public var stackPageVC: [UIViewController]!
    public var stackStartLocation: Int = 0

    open var pageViewController: UIPageViewController!
    open var currentStackVC: UIViewController!

    public var currentVCIndex: Int {
        return stackPageVC.firstIndex(of: currentStackVC) ?? 0
    }

    // Tab bar customization
    public var tabBarHeight: CGFloat = 100
    public var tabBarBackgroundColor: UIColor = .systemBackground {
        didSet { tabBar.barBackgroundColor = tabBarBackgroundColor }
    }
    public var tabBarSelectedTintColor: UIColor = UIColor(named: "AccentColor")! {
        didSet { tabBar.selectedTintColor = tabBarSelectedTintColor }
    }
    public var tabBarUnselectedTintColor: UIColor = .systemGray {
        didSet { tabBar.unselectedTintColor = tabBarUnselectedTintColor }
    }
    public var tabBarShowTopBorder: Bool = true {
        didSet { tabBar.showTopBorder = tabBarShowTopBorder }
    }
    public var tabBarTopBorderColor: UIColor = .separator {
        didSet { tabBar.topBorderColor = tabBarTopBorderColor }
    }

    // MARK: - Private Properties
    public let tabBar = EZSwipeTabBar()
    private var tabItems: [EZSwipeTabItem] = []

    // MARK: - Initialization
    public init() {
        super.init(nibName: nil, bundle: nil)
        setupView()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    open func setupView() {
        // Override point for subclasses
    }

    // MARK: - Lifecycle
    override open func loadView() {
        super.loadView()

        guard let ds = datasource else {
            print("EZSwipeTabController: datasource not set")
            return
        }

        stackVC = ds.viewControllerData()
        tabItems = ds.tabItemsData()
        stackStartLocation = ds.indexOfStartingPage()

        guard stackVC.count == tabItems.count else {
            print("EZSwipeTabController: viewControllerData count must match tabItemsData count")
            return
        }

        setupTabBar()
        setupViewControllers()
        setupPageViewController()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Setup Methods
    private func setupTabBar() {
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabBar)

        NSLayoutConstraint.activate([
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: tabBarHeight + view.safeAreaInsets.bottom)
        ])

        tabBar.configure(with: tabItems, selectedIndex: stackStartLocation)

        tabBar.onTabSelected = { [weak self] index in
            self?.moveToPage(index, animated: true)
        }
    }

    private func setupViewControllers() {
        stackPageVC = []

        for viewController in stackVC {
            let pageVC = UIViewController()
            viewController.view.frame = pageVC.view.bounds
            viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            pageVC.addChild(viewController)
            pageVC.view.addSubview(viewController.view)
            viewController.didMove(toParent: pageVC)

            stackPageVC.append(pageVC)
        }

        currentStackVC = stackPageVC[stackStartLocation]
    }

    private func setupPageViewController() {
        pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )

        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.setViewControllers(
            [stackPageVC[stackStartLocation]],
            direction: .forward,
            animated: false,
            completion: nil
        )

        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.view.backgroundColor = .clear

        addChild(pageViewController)
        view.insertSubview(pageViewController.view, belowSubview: tabBar)

        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
        ])

        pageViewController.didMove(toParent: self)
    }

    // MARK: - Public Methods
    public func moveToPage(_ index: Int, animated: Bool) {
        guard index >= 0 && index < stackPageVC.count else { return }

        let currentIndex = stackPageVC.firstIndex(of: currentStackVC) ?? 0
        guard index != currentIndex else { return }

        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse

        currentStackVC = stackPageVC[index]
        tabBar.setSelectedIndex(index, animated: animated)
        //datasource?.changedToPageIndex?(index)

        pageViewController.setViewControllers(
            [currentStackVC],
            direction: direction,
            animated: animated,
            completion: nil
        )
    }
}

// MARK: - UIPageViewControllerDataSource
extension EZSwipeTabController: UIPageViewControllerDataSource {

    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = stackPageVC.firstIndex(of: viewController), index > 0 else {
            return nil
        }
        return stackPageVC[index - 1]
    }

    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let index = stackPageVC.firstIndex(of: viewController), index < stackPageVC.count - 1 else {
            return nil
        }
        return stackPageVC[index + 1]
    }
}

// MARK: - UIPageViewControllerDelegate
extension EZSwipeTabController: UIPageViewControllerDelegate {

    public func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let visibleVC = pageViewController.viewControllers?.first,
              let newIndex = stackPageVC.firstIndex(of: visibleVC) else {
            return
        }

        currentStackVC = stackPageVC[newIndex]
        tabBar.setSelectedIndex(newIndex, animated: true)
        //datasource?.changedToPageIndex?(newIndex)
    }
}
