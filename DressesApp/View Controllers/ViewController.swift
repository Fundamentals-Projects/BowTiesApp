//
//  ViewController.swift
//  DressesApp
//
//  Created by Omairys Uzcátegui on 2021-09-12.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var timesWornLabel: UILabel!
    @IBOutlet weak var lastWornLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var currentDress: Dresses!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //1
        insertSampleData()
        
        //2
        let request: NSFetchRequest<Dresses> = Dresses.fetchRequest()
        let firstTitle = segmentedControl.titleForSegment(at: 0)!
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(Dresses.searchKey), firstTitle])
        do{
            //3
            let results = try managedContext.fetch(request)
            currentDress = results.first
            //4
            populate(dresses: results.first!)
        }catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func segmentedControl(_ sender: Any) {
        guard let control = sender as? UISegmentedControl,
              let selectedValue = control.titleForSegment(at: control.selectedSegmentIndex) else { return }
        
        let request = NSFetchRequest<Dresses>(entityName: "Dresses")
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(Dresses.searchKey), selectedValue])
        
        do {
            let results = try managedContext.fetch(request)
            currentDress = results.first
            populate(dresses: currentDress)
        } catch let error as NSError {
            print ("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func wear(_ sender: Any) {
        let times = currentDress.tiemesWorn
        currentDress.tiemesWorn = times + 1
        currentDress.lastWorn = Date()
        
        do {
            try managedContext.save()
            populate(dresses: currentDress)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func rate(_ sender: Any) {
        let alert = UIAlertController(title: "New Rating", message: "Rate this Dress", preferredStyle: .alert)
        alert.addTextField { (textField) in textField.keyboardType = .decimalPad }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            
            guard let textField = alert.textFields?.first else {
                return
            }
            self.update(rating: textField.text)
        }
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        present(alert, animated: true)
    }
    
    func update(rating: String?) {
        guard let ratingString = rating, let rating = Double (ratingString) else {
            return
        }
        
        do {
            currentDress.rating = rating
            try managedContext.save()
            populate(dresses: currentDress)
        } catch let error as NSError {
            if error.domain == NSCocoaErrorDomain && (error.code == NSValidationNumberTooLargeError || error.code == NSValidationNumberTooSmallError) {
                rate(currentDress!)
            } else {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    func populate(dresses :Dresses){
        guard let imageData = dresses.photoData as Data?,
              let lastWorn = dresses.lastWorn as Date?,
              let tintColor = dresses.tintColor as? UIColor else {
            return
        }
        
        imageView.image = UIImage(data: imageData)
        nameLabel.text = dresses.name
        ratingLabel.text = "Rating: \(dresses.rating)/5"
        timesWornLabel.text = "# time worn: \(dresses.tiemesWorn)"
        let dateFormater = DateFormatter()
        dateFormater.dateStyle = .short
        dateFormater.timeStyle = .none
        
        lastWornLabel.text = "Last worm: " + dateFormater.string(from: lastWorn)
        
        favoriteLabel.isHidden = !dresses.isFavorite
        view.tintColor = tintColor
    }
    
    func insertSampleData(){
        let fetch: NSFetchRequest<Dresses> = Dresses.fetchRequest()
        fetch.predicate = NSPredicate(format: "searchKey != nil")

        let count = try! managedContext.count(for: fetch)
        
        if count > 0 {
            return
        }
        
        let path = Bundle.main.path(forResource: "SampleData", ofType: "plist")
        let dataArray = NSArray(contentsOfFile: path!)!
        
        for dict in dataArray {
            let entity = NSEntityDescription.entity(forEntityName: "Dresses", in: managedContext)!
            let dresses = Dresses(entity: entity, insertInto: managedContext)
            
            let drDict = dict as! [String: Any]
            
            dresses.id = UUID(uuidString: drDict["id"] as! String)
            dresses.name = drDict["name"] as? String
            dresses.searchKey = drDict["searchKey"] as? String
            dresses.rating = drDict["rating"] as! Double
            
            let colorDict = drDict["tintColor"] as! [String: Any]
            dresses.tintColor = UIColor.color(dict: colorDict)
            
            let imageName = drDict["imageName"] as? String
            let image = UIImage(named: imageName!)
            //let photoData = UIImagePNGRepresentation(image!)!
            dresses.photoData = image?.jpegData(compressionQuality: 0.8)
            dresses.lastWorn = drDict["lastWorn"] as? Date
            let timesNumber = drDict["timesWorn"] as! NSNumber
            dresses.tiemesWorn = timesNumber.int32Value
            dresses.isFavorite = drDict["isFavorite"] as! Bool
            dresses.url = URL(string: drDict["url"] as! String)
        }
        try! managedContext.save()
    }

}

private extension UIColor {
  static func color(dict: [String : Any]) -> UIColor? {
    guard let red = dict["red"] as? NSNumber,
      let green = dict["green"] as? NSNumber,
      let blue = dict["blue"] as? NSNumber else { return nil }
    
    return UIColor(red: CGFloat(truncating: red) / 255.0,
                 green: CGFloat(truncating: green) / 255.0,
                 blue: CGFloat(truncating: blue) / 255.0,
                 alpha: 1)
  }
}



