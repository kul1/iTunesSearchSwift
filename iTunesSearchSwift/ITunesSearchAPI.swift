import UIKit

protocol ITunesSearchAPIProtocol {
    func didRecieveResponse(results: NSDictionary)
}

class ITunesSearchAPI: NSObject {
    var data: NSMutableData = NSMutableData()
    var delegate: ITunesSearchAPIProtocol?
    
    //Search iTunes
    func searchItunesFor(searchTerm: String) {
        
        //Clean up the search terms by replacing spaces with +
        var itunesSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+",
            options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        var escapedSearchTerm = itunesSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
//        var urlPath = "https://itunes.apple.com/search?term=\(escapedSearchTerm)&media=music"
        var urlPath = ("https://itunes.apple.com/search?term="+(escapedSearchTerm)!+"&media=music")


        var url: NSURL = NSURL(string: urlPath)!
        println(url)
        

        var request: NSURLRequest = NSURLRequest(URL: url)
        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self,
            startImmediately: false)!
        
        println("Search iTunes API at URL \(url)")
        
        connection.start()            
        

    }
    
    //NSURLConnection delegate method
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        println("Failed with error:\(error.localizedDescription)")
    }
    
    //NSURLConnection delegate method
    func connection(didReceiveResponse: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        //New request so we need to clear the data object
        self.data = NSMutableData()
    }
    
    //NSURLConnection delegate method
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        //Append incoming data
        self.data.appendData(data)
    }
    
    //NSURLConnection delegate method
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        //Finished receiving data and convert it to a JSON object
        var err: NSError
        var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data,
            options:NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
        
        delegate?.didRecieveResponse(jsonResult)
    }
    
}