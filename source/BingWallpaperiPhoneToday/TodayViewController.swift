//
//  TodayViewController.swift
//  BingWallpaperiPhoneToday
//
//  Created by Chris Comeau on 2018-06-04.
//

import UIKit
import NotificationCenter
import Foundation
import Alamofire
import AlamofireImage

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var label: UILabel!

    /*let imageCache = AutoPurgingImageCache(
        memoryCapacity: UInt64(100).megabytes(),
        preferredMemoryUsageAfterPurge: UInt64(60).megabytes()
    )*/

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //rounded
        imageView.layer.cornerRadius = 8.0
        imageView.clipsToBounds = true

        //self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        /*
        if let prefs = UserDefaults(suiteName: App.appGroup) {
            var nomDateAffichage: String
            if App.estFrancais {
                nomDateAffichage = "dateAffichageProverbesFR"
            } else {
                nomDateAffichage = "dateAffichageProverbesEN"
            }
            prefs.set(NSDate(), forKey: nomDateAffichage)
        } else {
            afficherErreur(codeErreurUserDefaultViewDidLoad)
            return
        }
         */

    }
    
    override func viewDidLayoutSubviews() {
        print("viewDidLayoutSubviews is called")
        // Initial state of my animation.
        
        //force resize, align top
        //self.label.sizeToFit()

        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updatePreferredContentSize() {
            /*if self.extensionContext?.widgetActiveDisplayMode == .expanded {
                //ne pas faire en compact
                preferredContentSize = CGSize(width:CGFloat(0), height:200)
            }*/
    }
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        
        /*self.updatePreferredContentSize()

        if activeDisplayMode == .expanded {
         
        } else if activeDisplayMode == .compact {
         
        }*/
    }


    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {

        let url = URL(string:"???")
			
        
        //image view alamo
        self.imageView.af_setImage(
            withURL: URL(string:"???")!,
            placeholderImage: UIImage(named: "placeholder")
        )
			
			
        
        Alamofire.request("???")
         .responseString { response in
         
             if let string = response.result.value {
                //print("image downloaded: \(image)")
                self.label.text = string
             }
             else{
                self.label.text = "(No description available)"
             }
         }

        
        
        
        //done
        completionHandler(NCUpdateResult.newData)
    }
    
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        //enlever marge
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }

    
    @IBAction func actionApp(_ sender: UIButton) {
        var urlString1: String = "dailywallpaper://"
        
        let urlString2: NSString = urlString1 as NSString
        urlString1 =  urlString2.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        let appURL = NSURL(string: urlString1)
        
        self.extensionContext?.open(appURL! as URL, completionHandler: nil)
    }

    
}
