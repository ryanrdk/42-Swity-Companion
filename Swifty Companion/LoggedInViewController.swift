import UIKit

class LoggedInViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //    IMAGES
    @IBOutlet weak var userImage: UIImageView!
    var clientlogged:Client = Client()
    @IBOutlet weak var backgroundImage: UIImageView!
    var connection:APIConnection = APIConnection()
    @IBOutlet weak var userLoginTextLabel: UILabel!

    //    TEXT_FIELD
    @IBOutlet weak var firstnameTextLabel: UILabel!
    @IBOutlet weak var lastnameTextLabel: UILabel!
    @IBOutlet weak var levelTextLabel: UILabel!
    @IBOutlet weak var levelProgressBar: UIProgressView!


    //    EVENTS_BUTTON
    @IBOutlet weak var eventButton: UIButton!
    @IBAction func eventsButtonPress(_ sender: Any) {
        //load events
        getEvents()
        sleep(3)
        loadEventsScreen()
    }

    //     CURSUS TABLE
    @IBOutlet weak var cursusTableView: UITableView!
    //a list to store DataModel
    var dataModels = [DataModel]()



    func getEvents() {
        //get token
        connection.genTok{ (token) in
            print("Token is \(token)")
            //user requests in here with token
            self.clientlogged.getEventsInfo(token: token) { events in
                //                print("EVENTS")
            }
            self.clientlogged.getCampusInfo(token: token) { campuses in
                print(campuses)
                self.clientlogged.getCursusInfo(token: token) { cursuses in
                    print(cursuses)
                }
            }

        }
    }

    func loadEventsScreen() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let eventTableViewController = storyBoard.instantiateViewController(withIdentifier: "EventTableViewController") as! EventTableViewController
        eventTableViewController.client = clientlogged
        eventTableViewController.conn = connection
        self.navigationController?.pushViewController(eventTableViewController, animated: true)
        //        self.present(loggedInViewController, animated: true, completion: nil)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        //        self.navigationItem.leftBarButtonItem?.title = "Logout"
        viewWillDisappear(false)
        userLoginTextLabel?.text = clientlogged.userLogin
        firstnameTextLabel?.text = clientlogged.userFirstName
        lastnameTextLabel?.text = clientlogged.userLastName
        levelTextLabel?.text = "Level " + String(Int(clientlogged.userLevel))
        levelProgressBar?.progress = Float(clientlogged.userLevel - Double(Int(clientlogged.userLevel)))

        let activityView = UIActivityIndicatorView(style: .large)
        activityView.center = userImage.center
        userImage.addSubview(activityView)
        activityView.startAnimating()

        if (self.verifyUrl(urlString: clientlogged.userPhoto)) {
            load_image(clientlogged.userPhoto, imageview:userImage, activityView:activityView)
        } else {
            let alert = AlertHelper()
            alert.showAlert(fromController: self, messages: "Error loading user image.")
        }

        for i in 0..<clientlogged.cursusNames.count{

            self.dataModels.append(DataModel(cursusLabel: clientlogged.cursusNames[i], cursusBarValue: (clientlogged.cursusLevels[i] / 20)))
            //displaying data in tableview
            self.cursusTableView.reloadData()

        }
    }

    //    Shows Navbar
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
            print("Disconnect from API")
        }
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    //the method returning size of the list
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return dataModels.count
    }

    //the method returning each cell of the list
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CursusTableViewCell

        //getting the hero for the specified position
        let model: DataModel

        model = dataModels [indexPath.row]

        //displaying values
        cell.cursusLabel.text = model.cursusLabel
        cell.cursusBar.progress = Float(Double(model.cursusBarValue ?? 0.50))

        return cell

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func verifyUrl(urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }

    func load_image(_ link:String, imageview:UIImageView,  activityView: UIActivityIndicatorView)
    {

        let url:URL = URL(string: link)!

        let session = URLSession.shared

        let request = NSMutableURLRequest(url: url)
        request.timeoutInterval = 10


        let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            guard let _:Data = data, let _:URLResponse = response, error == nil else {
                var alert = AlertHelper()
                alert.showAlert(fromController: self, messages: "Invalid image")

                return
            }

            print("Download Started\n")
            var image = UIImage(data: data!)
            //            activityView.stopAnimating()

            if (image != nil) {
                func set_image()
                {
                    //                    self.images_cache[link] = image
                    imageview.image = image

                    activityView.stopAnimating()
                    //                    UIApplication.shared.isNetworkActivityIndicatorVisible = false

                }
                print("Download Finished\n")
                DispatchQueue.main.async(execute: set_image)
            }
        })

        task.resume()

    }
}

class DataModel {

    var cursusLabel: String?
    var cursusBarValue: Double?

    init(cursusLabel: String?, cursusBarValue: Double?) {
        self.cursusLabel = cursusLabel
        self.cursusBarValue = cursusBarValue
    }
}
