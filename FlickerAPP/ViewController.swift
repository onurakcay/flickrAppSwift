//
//  ViewController.swift
//  FlickerAPP
//
//  Created by Onur AKÇAY on 7.09.2019.
//  Copyright © 2019 Onur AKÇAY. All rights reserved.
//

import UIKit
import Foundation
class ViewController: UIViewController {

    @IBOutlet weak var flickerImageView: UIImageView!
    @IBOutlet weak var flickerTextField: UITextField!
    @IBOutlet weak var flickerButton: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    var counter = 0
    var arraycounter = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        counter = 0
        
        let searchURL = flickrURLFromParameters()
        print("URL: \(searchURL)")
        
        // Send the request
        performFlickrSearch(searchURL)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.Page, value: Constants.FlickrAPIValues.Page));
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.Perpage, value: Constants.FlickrAPIValues.Perpage));
        components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.SearchMethod, value: Constants.FlickrAPIValues.SearchMethod));
        return components.url!
    }
    
    @IBAction func nextButton(_ sender: Any) {

        if counter < arraycounter-1 {
        counter+=1
        }
        else{
            nextBtn.isEnabled = false
        }
    
        
        let searchURL = flickrURLFromParameters()
        performFlickrSearch(searchURL)
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
                    parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                } catch {
                    self.displayAlert("Could not parse the data as JSON: '\(data)'")
                    return
                }
                //print("Result: \(parsedResult)")
                
                // Check for "photos" key in our result
                guard let photosDictionary = parsedResult["photos"] as? [String:AnyObject] else {
                    self.displayAlert("Key 'photos' not in \(parsedResult)")
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
                    let photoDictionary = photosArray[self.counter] as [String: AnyObject]
                    
                    /* GUARD: Does our photo have a key for 'url_m'? */
                    guard let imageUrlString = photoDictionary["url_m"] as? String else {
                        self.displayAlert("Cannot find key 'url_m' in \(photoDictionary)")
                        return
                    }
                    guard let title = photoDictionary["title"] as? String else {
                        self.displayAlert("Cannot find key 'title' in \(photoDictionary)")
                        return
                    }
                    // Fetch the image
                    self.fetchImage(imageUrlString,title);
                }
                
            }
            else{
                self.displayAlert((error?.localizedDescription)!)
            }
        }
        task.resume()
    }
    
    private func fetchImage(_ url: String,_ title: String) {
        
        let imageURL = URL(string: url)
        let title = String(describing: title)
        let task = URLSession.shared.dataTask(with: imageURL!) { (data, response, error) in
            if error == nil {
                let downloadImage = UIImage(data: data!)!
                
                DispatchQueue.main.async(){
                    self.flickerImageView.image = downloadImage
                    self.titleLabel.text = title
                    print("================================================")
                    print("count: \(self.counter)")
                    print("ArrayCounter: \(self.arraycounter)")
                    self.counterLabel.text  = String(self.counter+1)+"/"+String(self.arraycounter)
                }
            }
        }
        
        task.resume()
    }
    
    func displayAlert(_ message: String)
    {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Click", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

