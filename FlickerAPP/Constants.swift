//
//  Constants.swift
//  FlickerAPP
//
//  Created by Onur AKÇAY on 7.09.2019.
//  Copyright © 2019 Onur AKÇAY. All rights reserved.
//

import Foundation
struct Constants {
    
    struct FlickrURLParams {
        static let APIScheme = "https"
        static let APIHost = "www.flickr.com"
        static let APIPath = "/services/rest"
    }
    
    struct FlickrAPIKeys {
        static let SearchMethod = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let ResponseFormat = "format"
        static let DisableJSONCallback = "nojsoncallback"
        static let Page = "page"
        static let Perpage = "per_page"
    }
    
    struct FlickrAPIValues {
        static let SearchMethod = "flickr.photos.getRecent"
        static let APIKey = "0d7d08de62850a340583dfae0362cb25"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let MediumURL = "url_m"
        static let Page = "1"
        static let Perpage = "5"
    }
}
