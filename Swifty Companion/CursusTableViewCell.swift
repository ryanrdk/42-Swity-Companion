import UIKit

class CursusTableViewCell: UITableViewCell {

    @IBOutlet weak var cursusLabel: UILabel!
    @IBOutlet weak var cursusBar: UIProgressView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
