//
//  ViewController.swift
//  FlickerAPP
//
//  Created by Onur AKÇAY on 7.09.2019.
//  Copyright © 2019 Onur AKÇAY. All rights reserved.
//

import UIKit
import SDWebImage
import Foundation
class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextBtn: UIButton!
    
    var counter = 0
    var arraycounter = 0
    var flickrImages = [String]()
    var flickrTitle = [String]()
    var chosenImageName = ""
    var chosenImage = ""
    var refreshControl = UIRefreshControl()
    var fetchingMore = false
    var arraysize = 5
    var pageNumber = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self

        
        let searchURL = flickrURLFromParameters()
        print("searchurlmain : \(searchURL)")
        performFlickrSearch(searchURL)
        // Send the request
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
       
        
    }
    @objc func refresh(sender:AnyObject) {
        DispatchQueue.main.async { self.tableView.reloadData() }
        let searchURL = flickrURLFromParameters()
        
        performFlickrSearch(searchURL)
        
        refreshControl.endRefreshing()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        //print("offsety : \(offsetY)|contentHeight: \(contentHeight)")
        
        if offsetY > contentHeight - scrollView.frame.height * 2 {
            if !fetchingMore
            {
                beginMoreFetch()
                
            }
        }
    }
    func beginMoreFetch() {
        fetchingMore = true
        print("beginFetch")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.counter = 0
            self.pageNumber+=1
            let searchURL = self.flickrURLFromParameters()
            print("searchurlsecond : \(searchURL)")
            self.performFlickrSearch(searchURL)
            
            self.fetchingMore = false
            
        self.tableView.reloadData()
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCell
        cell.titleLabel.text="test"
        cell.flickrImage.image = UIImage(named: "click.jpg")
        if flickrImages.isEmpty == false && flickrTitle.isEmpty == false{
            //print("arrayson: \(self.flickrImages)")
            cell.flickrImage.sd_setImage(with: URL(string: self.flickrImages[indexPath.row]))
            cell.titleLabel.text = self.flickrTitle[indexPath.row]
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arraysize
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenImageName = self.flickrTitle[indexPath.row]
        chosenImage = self.flickrImages[indexPath.row]
        performSegue(withIdentifier: "toImageViewController", sender: nil)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toImageViewController" {
            let destinationVC = segue.destination as! imageViewController
            destinationVC.selectedImageName = chosenImageName
            destinationVC.selectedImage = chosenImage
        }
    }
   
    
    private func flickrURLFromParameters() -> URL {
        
        // Build base URL
        var components = URLComponents()
        components.scheme = Constants.FlickrURLParams.APIScheme
        components.host = Constants.FlickrURLParams.APIHost
        components.path = Constants.FlickrURLParams.APIPath
        
        // Build query string
        components.queryItems = [URLQueryItem]()
        
        // Query components
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.APIKey, value: Constants.FlickrAPIValues.APIKey));
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.ResponseFormat, value: Constants.FlickrAPIValues.ResponseFormat));
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.Extras, value: Constants.FlickrAPIValues.MediumURL));
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.DisableJSONCallback, value: Constants.FlickrAPIValues.DisableJSONCallback));
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.Page, value:String( pageNumber)));
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.Perpage, value: Constants.FlickrAPIValues.Perpage));
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.SearchMethod, value: Constants.FlickrAPIValues.SearchMethod));
        return components.url!
    }
    
    
    private func performFlickrSearch(_ searchURL: URL) {
        
        // Perform the request
        let session = URLSession.shared
        let request = URLRequest(url: searchURL)
        let task = session.dataTask(with: request){
            (data, response, error) in
            if (error == nil)
            {
                // Check response code
                let status = (response as! HTTPURLResponse).statusCode
                if (status < 200 || status > 300)
                {
                    self.displayAlert("Server returned an error")
                    return;
                }
                
                /* Check data returned? */
                guard let data = data else {
                    self.displayAlert("No data was returned by the request!")
                    return
                }
                
                // Parse the data
                let parsedResult: [String:AnyObject]!
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
                } catch {
                    self.displayAlert("Could not parse the data as JSON: '\(data)'")
                    return
                }
                //print("Result: \(parsedResult)")
                
                // Check for "photos" key in our result
                guard let photosDictionary = parsedResult["photos"] as? [String:AnyObject] else {
                    self.displayAlert("Key 'photos' not in \(String(describing: parsedResult))")
                    return
                }
                
                
                /* GUARD: Is the "photo" key in photosDictionary? */
                guard let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] else {
                    self.displayAlert("Cannot find key 'photo' in \(photosDictionary)")
                    return
                }
                print("Result: \(photosArray)")
                // Check number of ophotos
                if photosArray.count == 0 {
                    self.displayAlert("No Photos Found. Search Again.")
                    return
                } else {
                    self.arraycounter = photosArray.count
                    // Get the first image
                   
                    while self.counter<5{
                        
                    let photoDictionary = photosArray[self.counter] as [String: AnyObject]
                        if(photoDictionary["url_m"] != nil){
                    self.flickrImages.append(photoDictionary["url_m"] as! String)
                            
                        }
                    self.flickrTitle.append(photoDictionary["title"] as! String)
                        /* GUARD: Does our photo have a key for 'url_m'? */
//                        guard let imageUrlString = photoDictionary["url_m"] as? String else {
//                            self.displayAlert("Cannot find key 'url_m' in \(photoDictionary)")
//                            return
//                        }
//                        guard let title = photoDictionary["title"] as? String else {
//                            self.displayAlert("Cannot find key 'title' in \(photoDictionary)")
//                            return
//                        }
                        // Fetch the image
                        self.counter+=1
                    }
                    if(self.fetchingMore == true){
                        self.arraysize = self.arraysize + 5
                        self.tableView.reloadData()
                        
                    }
                    
                    
                     print("array: \(self.flickrImages)")
                    print("arraysize : \(self.arraysize)")
                }
                
            }
            else{
                self.displayAlert((error?.localizedDescription)!)
            }
        }
        task.resume()
    }
    
//    private func fetchImage(_ url: String,_ title: String) {
//
//        let imageURL = URL(string: url)
//        let title = String(describing: title)
//        let task = URLSession.shared.dataTask(with: imageURL!) { (data, response, error) in
//            if error == nil {
//                let downloadImage = UIImage(data: data!)!
//
//                DispatchQueue.main.async(){
//
//                    self.logoImages.append(downloadImage)
//
//                  // self.imageView.image = self.logoImages[1]
//
//
//                    /*self.flickerImageView.image = downloadImage
//                    self.titleLabel.text = title
//                    print("================================================")
//                    print("count: \(self.counter)")
//                    print("ArrayCounter: \(self.arraycounter)")
//                    self.counterLabel.text  = String(self.counter+1)+"/"+String(self.arraycounter)*/
//                }
//            }
//        }
//
//        task.resume()
//    }
    
    func displayAlert(_ message: String)
    {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Click", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
   
}

