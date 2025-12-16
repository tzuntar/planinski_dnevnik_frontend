import UIKit

protocol DropdownTextFieldDelegate: AnyObject {
    func dropdownTextField(_ dropdownTextField: DropdownTextField, didSelectOption option: String)
    func dropdownTextFieldDidChangeText(_ dropdownTextField: DropdownTextField, text: String)
}

extension DropdownTextFieldDelegate {
    func dropdownTextFieldDidChangeText(_ dropdownTextField: DropdownTextField, text: String) {}
}

@IBDesignable
class DropdownTextField: UIView {

    // MARK: - Outlets
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var dropdownButton: UIButton!
    @IBOutlet weak var containerView: UIView!

    // MARK: - Properties
    weak var delegate: DropdownTextFieldDelegate?

    private var dropdownTableView: UITableView?
    private var dropdownBackgroundView: UIView?
    private var isDropdownVisible = false

    var options: [String] = [] {
        didSet {
            dropdownTableView?.reloadData()
        }
    }

    var text: String {
        get { textField.text ?? "" }
        set { textField.text = newValue }
    }

    @IBInspectable var placeholder: String? {
        get { textField.placeholder }
        set { textField.placeholder = newValue }
    }

    @IBInspectable var maxDropdownHeight: CGFloat = 200

    private let rowHeight: CGFloat = 44

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
        setupView()
    }

    private func loadNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "DropdownTextField", bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }

    private func setupView() {
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor(red: 0.076, green: 0.169, blue: 0.0, alpha: 1.0).cgColor
        containerView.clipsToBounds = true

        textField.borderStyle = .none
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        let chevronImage = UIImage(systemName: "chevron.down")
        dropdownButton.setImage(chevronImage, for: .normal)
        dropdownButton.tintColor = UIColor(red: 0.076, green: 0.169, blue: 0.0, alpha: 1.0)
        dropdownButton.addTarget(self, action: #selector(dropdownButtonTapped), for: .touchUpInside)
    }

    // MARK: - Actions
    @objc private func dropdownButtonTapped() {
        if isDropdownVisible {
            hideDropdown()
        } else {
            showDropdown()
        }
    }

    @objc private func textFieldDidChange() {
        delegate?.dropdownTextFieldDidChangeText(self, text: text)
    }

    // MARK: - Dropdown Management
    private func showDropdown() {
        guard !options.isEmpty else { return }
        guard let window = window else { return }

        isDropdownVisible = true

        // rotate chevron
        UIView.animate(withDuration: 0.2) {
            self.dropdownButton.transform = CGAffineTransform(rotationAngle: .pi)
        }

        dropdownBackgroundView = UIView(frame: window.bounds)
        dropdownBackgroundView?.backgroundColor = .clear
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        dropdownBackgroundView?.addGestureRecognizer(tapGesture)
        window.addSubview(dropdownBackgroundView!)

        let frameInWindow = convert(bounds, to: window)
        let tableHeight = min(CGFloat(options.count) * rowHeight, maxDropdownHeight)
        let tableFrame = CGRect(
            x: frameInWindow.origin.x,
            y: frameInWindow.maxY + 4,
            width: frameInWindow.width,
            height: tableHeight
        )

        dropdownTableView = UITableView(frame: tableFrame, style: .plain)
        dropdownTableView?.delegate = self
        dropdownTableView?.dataSource = self
        dropdownTableView?.layer.cornerRadius = 8
        dropdownTableView?.layer.borderWidth = 1
        dropdownTableView?.layer.borderColor = UIColor(red: 0.076, green: 0.169, blue: 0.0, alpha: 1.0).cgColor
        dropdownTableView?.clipsToBounds = true
        dropdownTableView?.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        dropdownTableView?.backgroundColor = UIColor(red: 0.968, green: 0.990, blue: 0.950, alpha: 1.0)
        dropdownTableView?.register(UITableViewCell.self, forCellReuseIdentifier: "DropdownCell")

        // for the shadow
        dropdownTableView?.layer.shadowColor = UIColor.black.cgColor
        dropdownTableView?.layer.shadowOffset = CGSize(width: 0, height: 2)
        dropdownTableView?.layer.shadowOpacity = 0.15
        dropdownTableView?.layer.shadowRadius = 4
        dropdownTableView?.layer.masksToBounds = false

        // animate in
        dropdownTableView?.alpha = 0
        dropdownTableView?.transform = CGAffineTransform(translationX: 0, y: -10)
        window.addSubview(dropdownTableView!)

        UIView.animate(withDuration: 0.2) {
            self.dropdownTableView?.alpha = 1
            self.dropdownTableView?.transform = .identity
        }
    }

    func hideDropdown() {
        guard isDropdownVisible else { return }

        isDropdownVisible = false

        UIView.animate(withDuration: 0.2) {
            self.dropdownButton.transform = .identity
        }

        UIView.animate(withDuration: 0.15, animations: {
            self.dropdownTableView?.alpha = 0
            self.dropdownTableView?.transform = CGAffineTransform(translationX: 0, y: -10)
        }) { _ in
            self.dropdownTableView?.removeFromSuperview()
            self.dropdownTableView = nil
            self.dropdownBackgroundView?.removeFromSuperview()
            self.dropdownBackgroundView = nil
        }
    }

    @objc private func backgroundTapped() {
        hideDropdown()
        textField.resignFirstResponder()
    }

    // MARK: - Public Methods
    func setOptions(_ options: [String]) {
        self.options = options
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension DropdownTextField: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropdownCell", for: indexPath)
        cell.textLabel?.text = options[indexPath.row]
        cell.textLabel?.font = UIFont(name: "Outfit-Thin_Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        cell.textLabel?.textColor = UIColor(red: 0.076, green: 0.169, blue: 0.0, alpha: 1.0)
        cell.backgroundColor = UIColor(red: 0.968, green: 0.990, blue: 0.950, alpha: 1.0)
        cell.selectionStyle = .default

        let selectedBgView = UIView()
        selectedBgView.backgroundColor = UIColor(red: 0.076, green: 0.169, blue: 0.0, alpha: 0.1)
        cell.selectedBackgroundView = selectedBgView

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedOption = options[indexPath.row]
        textField.text = selectedOption
        hideDropdown()
        delegate?.dropdownTextField(self, didSelectOption: selectedOption)
    }
}

// MARK: - UITextFieldDelegate
extension DropdownTextField: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideDropdown()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
