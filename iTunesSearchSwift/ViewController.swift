import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ITunesSearchAPIProtocol, UISearchBarDelegate, UISearchDisplayDelegate, UITextFieldDelegate {
    


    @IBOutlet weak var searchItem: UITextField! = UITextField()
    
    
    @IBOutlet var appsTableView : UITableView!
    var api: ITunesSearchAPI = ITunesSearchAPI()
    var tableData: NSArray = NSArray()
    var imageCache = NSMutableDictionary()
//    searchItem.text = "Jimmy Buffett"

    @IBAction func searchBtn(sender: AnyObject) {
        api.delegate = self;
        api.searchItunesFor(searchItem.text)
        if (searchItem.text.isEmpty) {
            searchItem.text = "Taylor"
        }
        
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        println("return key pressed")
        return true
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        println("Touch screen")
        self.view.endEditing(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchItem.delegate = self // To hide keyboard
        
        // Do any additional setup after loading the view, typically from a nib.
        
            }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didRecieveResponse(results: NSDictionary) {
        // Store the results in our table data array
        println("Received results")
        if results.count>0 {
            self.tableData = results["results"] as NSArray
            self.appsTableView.reloadData()
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
        
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let kCellIdentifier: String = "Cell"
        
        //the tablecell is optional to see if we can reuse cell
        let cell:CustomCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as CustomCell

        

        
        //Get our data row
        var rowData: NSDictionary = self.tableData[indexPath.row] as NSDictionary
        
        //Set the track name
        let cellText: String = rowData["trackName"] as String!
        cell.leftLabel.text = cellText
        // Get the track censored name
        var trackCensorName: NSString = rowData["collectionCensoredName"] as NSString
        cell.centerLabel.text = trackCensorName
        
        cell.cellImage.image = UIImage(named: "loading")
        
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        
            // Grab the artworkUrl60 key to get an image URL
            var urlString: NSString = rowData["artworkUrl60"] as NSString
            
            // Check the image cache for the key (using the image URL as key)
            var image: UIImage? = self.imageCache.valueForKey(urlString) as? UIImage
            
            if urlString != "" {
                // If the image does not exist in the cache then we need to download it
                var imgURL: NSURL = NSURL(string: urlString)!
                
                //Get the image from the URL
                var request: NSURLRequest = NSURLRequest(URL: imgURL)
                var urlConnection: NSURLConnection = NSURLConnection(request: request,
                    delegate: self)!
                
                NSURLConnection.sendAsynchronousRequest(request, queue:
                    NSOperationQueue.mainQueue(), completionHandler: {(response:
                        NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                        
                        if !(error? != nil) {
                            image = UIImage(data: data)
                            
                            // Store the image in the cache
                            self.imageCache.setValue(image, forKey: urlString)
                            cell.imageView?.image = image
                            tableView.reloadData()
                        }
                        else {
                            println("Error: \(error.localizedDescription)")
                        }
                })
                
            }
            else {
                cell.imageView?.image = image
            }
        
            
        })
        
        
        return cell

        
    }
    

}