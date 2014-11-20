import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ITunesSearchAPIProtocol {
    
    
    
    
    @IBOutlet var appsTableView : UITableView!
    var api: ITunesSearchAPI = ITunesSearchAPI()
    var tableData: NSArray = NSArray()
    var imageCache = NSMutableDictionary()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        api.delegate = self;
        api.searchItunesFor("Jimmy Buffett")
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
        let kCellIdentifier: String = "MyCell"
        
        //the tablecell is optional to see if we can reuse cell
        var cell : UITableViewCell?
        cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as?
        UITableViewCell
        
        //If we did not get a reuseable cell, then create a new one
        if !(cell? != nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier:
                kCellIdentifier)
        }
        
        //Get our data row
        var rowData: NSDictionary = self.tableData[indexPath.row] as NSDictionary
        
        //Set the track name
        let cellText: String = rowData["trackName"] as String!
        cell?.textLabel?.text = cellText
        // Get the track censored name
        var trackCensorName: NSString = rowData["trackCensoredName"] as NSString
        cell!.detailTextLabel?.text = trackCensorName
        
        cell!.imageView?.image = UIImage(named: "loading")
        
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            // Grab the artworkUrl60 key to get an image URL
            var urlString: NSString = rowData["artworkUrl60"] as NSString
            
            // Check the image cache for the key (using the image URL as key)
            var image: UIImage? = self.imageCache.valueForKey(urlString) as? UIImage
            
            if image != nil {
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
                            cell!.imageView?.image = image
                            tableView.reloadData()
                        }
                        else {
                            println("Error: \(error.localizedDescription)")
                        }
                })
                
            }
            else {
                cell?.imageView?.image = image
            }
            
            
        })
        
        
        return cell!

        
    }
    

    
    
}