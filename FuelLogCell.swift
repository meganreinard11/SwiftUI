import UIKit

final class FuelLogCell: UITableViewCell {
    static let reuseID = "FuelLogCell"

    // Card container
    private let card = UIView()

    // Header (logo + date/amount + odometer)
    private let brandBadge = UIImageView()
    private let dateLabel = UILabel()
    private let amountLabel = UILabel()
    private let odoLabel = UILabel()
    private let subDistanceLabel = UILabel()

    // Rows (icon + text)
    private let gallonsRow = IconRowView(symbol: "drop.fill", tint: .systemPurple)
    private let mpgRow = IconRowView(symbol: "chart.line.uptrend.xyaxis")
    private let costRow = IconRowView(symbol: "dollarsign.circle", tint: .systemPurple)
    private let stationRow = IconRowView(symbol: "mappin.and.ellipse")

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 14
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowRadius = 6
        card.layer.shadowOffset = CGSize(width: 0, height: 2)

        brandBadge.contentMode = .scaleAspectFill
        brandBadge.clipsToBounds = true
        brandBadge.layer.cornerRadius = 22
        brandBadge.backgroundColor = .white

        dateLabel.font = .preferredFont(forTextStyle: .subheadline)
        dateLabel.textColor = .secondaryLabel

        amountLabel.font = .boldSystemFont(ofSize: 22)
        amountLabel.textColor = .label

        odoLabel.font = .boldSystemFont(ofSize: 22)
        odoLabel.textAlignment = .right

        subDistanceLabel.font = .systemFont(ofSize: 13)
        subDistanceLabel.textColor = .secondaryLabel
        subDistanceLabel.textAlignment = .right

        contentView.addSubview(card)
        [brandBadge, dateLabel, amountLabel, odoLabel, subDistanceLabel,
         gallonsRow, mpgRow, costRow, stationRow].forEach {
            card.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        card.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            brandBadge.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            brandBadge.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            brandBadge.widthAnchor.constraint(equalToConstant: 44),
            brandBadge.heightAnchor.constraint(equalToConstant: 44),

            dateLabel.leadingAnchor.constraint(equalTo: brandBadge.trailingAnchor, constant: 10),
            dateLabel.topAnchor.constraint(equalTo: brandBadge.topAnchor),

            amountLabel.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            amountLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 2),

            odoLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            odoLabel.topAnchor.constraint(equalTo: brandBadge.topAnchor),

            subDistanceLabel.trailingAnchor.constraint(equalTo: odoLabel.trailingAnchor),
            subDistanceLabel.topAnchor.constraint(equalTo: odoLabel.bottomAnchor, constant: 2),

            gallonsRow.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            gallonsRow.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            gallonsRow.topAnchor.constraint(equalTo: brandBadge.bottomAnchor, constant: 8),

            mpgRow.leadingAnchor.constraint(equalTo: gallonsRow.leadingAnchor),
            mpgRow.topAnchor.constraint(equalTo: gallonsRow.bottomAnchor, constant: 6),

            costRow.leadingAnchor.constraint(equalTo: mpgRow.trailingAnchor, constant: 12),
            costRow.topAnchor.constraint(equalTo: mpgRow.topAnchor),
            costRow.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -16),

            stationRow.leadingAnchor.constraint(equalTo: gallonsRow.leadingAnchor),
            stationRow.trailingAnchor.constraint(equalTo: gallonsRow.trailingAnchor),
            stationRow.topAnchor.constraint(equalTo: mpgRow.bottomAnchor, constant: 6),
            stationRow.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    /// Configure the cell with computed/derived values provided by the VC.
    func configure(brand: String?,
                   station: String?,
                   date: Date,
                   amount: Double,
                   gallons: Double,
                   pricePerGallon: Double,
                   odometer: Int,
                   distanceSince: Int?,
                   mpg: Double?,
                   costPerMile: Double?) {

        // Dynamic brand badge: uses asset if available, else initials
        brandBadge.image = BrandBadgeProvider.image(for: brand, station: station)

        dateLabel.text = DateFormatter.shortDate.string(from: date)
        amountLabel.text = amount.currency
        odoLabel.text = NumberFormatter.decimal.string(from: odometer as NSNumber)! + " mi"
        subDistanceLabel.text = distanceSince.map { NumberFormatter.decimal.string(from: $0 as NSNumber)! + " mi" }

        gallonsRow.text = "\(NumberFormatter.decimal2.string(from: gallons as NSNumber)!) gal ? \(pricePerGallon.currency)/gal"

        if let mpg = mpg {
            mpgRow.text = "\(NumberFormatter.decimal3.string(from: mpg as NSNumber)!) mpg"
            mpgRow.textColor = mpg < 20 ? .systemRed : .systemGreen
        } else {
            mpgRow.text = "— mpg"
            mpgRow.textColor = .label
        }

        if let cpm = costPerMile {
            costRow.text = "\(NumberFormatter.decimal3.string(from: cpm as NSNumber)!) $/mi"
        } else {
            costRow.text = "— $/mi"
        }

        stationRow.text = (brand?.isEmpty == false ? brand! + " " : "") + (station ?? "")
    }
}

// MARK: - Small "icon + label" view used in rows
final class IconRowView: UIView {
    private let icon = UIImageView()
    private let label = UILabel()

    init(symbol: String, tint: UIColor? = nil) {
        super.init(frame: .zero)
        icon.image = UIImage(systemName: symbol)
        icon.tintColor = tint ?? .secondaryLabel
        label.font = .systemFont(ofSize: 15)
        label.textColor = .label
        [icon, label].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; addSubview($0) }
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: leadingAnchor),
            icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 18),
            icon.heightAnchor.constraint(equalToConstant: 18),

            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 6),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    var text: String? { get { label.text } set { label.text = newValue } }
    var textColor: UIColor? { get { label.textColor } set { label.textColor = newValue } }
}

// MARK: - Formatters
private extension DateFormatter {
    static let shortDate: DateFormatter = {
        let f = DateFormatter(); f.dateStyle = .short; return f
    }()
}
private extension NumberFormatter {
    static let decimal: NumberFormatter = { let f = NumberFormatter(); f.numberStyle = .decimal; return f }()
    static let decimal2: NumberFormatter = { let f = NumberFormatter(); f.numberStyle = .decimal; f.minimumFractionDigits = 0; f.maximumFractionDigits = 2; return f }()
    static let decimal3: NumberFormatter = { let f = NumberFormatter(); f.numberStyle = .decimal; f.minimumFractionDigits = 0; f.maximumFractionDigits = 3; return f }()
}
private extension Double {
    var currency: String {
        let f = NumberFormatter(); f.numberStyle = .currency
        return f.string(from: self as NSNumber) ?? "$0.00"
    }
}
