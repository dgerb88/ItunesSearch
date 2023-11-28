//
//  ViewController.swift
//  ItunesSearch
//
//  Created by Dax Gerber on 11/27/23.
//

import UIKit

class ViewController: UIViewController {
    
    
    
    @IBOutlet weak var labelLabel2: UILabel!
    @IBOutlet weak var labelLabel: UILabel!
    @IBOutlet weak var labelLabel3: UILabel!
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func doTheWebStuff() async throws {
        let baseURL = URL(string: "https://itunes.apple.com/search")!
        let term = URLQueryItem(name: "term", value: searchTextField.text)
        let country = URLQueryItem(name: "country", value: "US")
        let media = URLQueryItem(name: "media", value: "music")
        var combineUrl = baseURL
        combineUrl.append(queryItems: [term, country, media])
        
        let (data, _) = try await URLSession.shared.data(from: combineUrl)
        let stringRep = String(data: data, encoding: .utf8)!
        print(stringRep)
        let jsonDecoder = JSONDecoder()
        let results = try jsonDecoder.decode(JaysawnData.self, from: data)
        let firstSong = results.results[0]
        labelLabel.text = firstSong.artistName
        labelLabel2.text = firstSong.genre
        labelLabel3.text = firstSong.trackName
        let imageURL = URL(string: firstSong.artwork)
        let (imageData, _) = try await URLSession.shared.data(from: imageURL!)
        image.image = UIImage(data: imageData)
    }
    
    @IBAction func searchButton(_ sender: UIButton) {
        Task {
            do {
                try await doTheWebStuff()
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
}







struct JaysawnData: Codable {
    var resultCount: Int
    var results: [SongData]
}


struct SongData: Codable {
    var artistName: String
    var trackName: String
    var genre: String
    var artwork: String
    var price: Double
    
    enum CodingKeys: String, CodingKey {
        case artistName
        case trackName
        case genre = "primaryGenreName"
        case artwork = "artworkUrl100"
        case price = "trackPrice"
    }
}
