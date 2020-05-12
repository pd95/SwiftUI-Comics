//
//  ViewModel.swift
//  iOS Comics
//
//  Created by Philipp on 13.05.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI
import Combine

class ViewModel: ObservableObject {
    var id: String = ""
    var strip: String = "Dilbert"
    var title: String = " "
    var imageUrl: String = ""
    var currentSlide: Date = Date()

    var image = UIImage(named: "Start")!
    let placeholder = UIImage(named: "Start")!

    var fetched = false
    var cancellable: AnyCancellable?

    let cache = NSCache<NSString,UIImage>()

    func refresh() {
        let request = URLRequest(url: URL(string: "https://dilbert.com/\(!id.isEmpty ? "strip/\(id)" : "")")!)

        cancellable = URLSession.shared
            .dataTaskPublisher(for: request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                print("completion: \(completion)")
            }, receiveValue: { (value) in
                let (data, response) = value
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response: \(response)")
                    return
                }
                guard httpResponse.statusCode == 200 else {
                    print("Invalid HTTP response: \(httpResponse)")
                    return
                }
                guard let html = String(data: data, encoding: .utf8) else {
                    fatalError("Unable to convert data to string")
                }
                guard let range = html.range(of: "<div.*class=\".*comic-item-container[^>]+", options: .regularExpression) else {
                    print("Unable to find comic data to in HTML")
                    return
                }

                var attributes=[String:String]()

                let dataDiv = String(html[range])
                let regex = try! NSRegularExpression(pattern: #"data-([^=]+)="([^"]+)""#, options: [])
                let nsrange = NSRange(dataDiv.startIndex..<dataDiv.endIndex,
                                      in: dataDiv)
                for match in regex.matches(in: dataDiv,
                                           options: [],
                                           range: nsrange)
                {
                    guard match.numberOfRanges == 3 else { continue }

                    let tag = String(dataDiv[Range(match.range(at: 1), in: dataDiv)!])
                    let value = String(dataDiv[Range(match.range(at: 2), in: dataDiv)!]).htmlDecoded
                    attributes[tag] = value
                }

                self.objectWillChange.send()

                let id = attributes["id"] ?? ""
                self.id = id
                self.title = attributes["title"] ?? "N/A"
                if let imageRef = attributes["image"] {
                    self.imageUrl = "https:\(imageRef)"
                }
                print("title = \(self.title)")
                print("imageUrl = \(self.imageUrl)")

                self.image = self.placeholder
                self.downloadImage(from: self.imageUrl) { image in
                    if let image = image {
                        DispatchQueue.main.async {
                            guard id == self.id else { return }
                            self.objectWillChange.send()
                            self.image = image
                        }
                    }
                }
            }
        )
    }

    private lazy var dateFormatter : DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "YYYY-MM-dd"
        return df
    }()

    func previousId() -> String {
        var date = dateFormatter.date(from: id) ?? Date()
        date.addTimeInterval(TimeInterval(-24 * 60 * 60))
        let newId = dateFormatter.string(from: date)
        print("previousId=\(newId)")
        return newId
    }

    func nextId() -> String {
        var date = dateFormatter.date(from: id) ?? Date()
        date.addTimeInterval(TimeInterval(24 * 60 * 60))
        let newId = dateFormatter.string(from: date)
        print("nextId=\(newId)")
        if date < Date() {
            return newId
        }
        return ""
    }

    func previousComic() {
        print("id=\(id)")
        id = previousId()
        refresh()
    }

    func nextComic() {
        let next = nextId()
        if next != id {
            id = next
            refresh()
        }
    }



    func downloadImage(from urlString: String, completed: @escaping (UIImage?) -> Void) {
        let cacheKey = NSString(string: urlString)
        print("urlString: \(urlString)")

        if let image = cache.object(forKey: cacheKey) {
            completed(image)
            return
        }

        guard let url = URL(string: urlString) else {
            completed(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil,
                let response = response as? HTTPURLResponse, response.statusCode == 200,
                let data = data,
                let image = UIImage(data: data) else {
                    completed(nil)
                    return
            }

            self.cache.setObject(image, forKey: cacheKey)

            completed(image)
        }

        task.resume()
    }
}

extension String {
    var htmlDecoded: String {
        let decoded = try? NSAttributedString(data: Data(utf8), options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ], documentAttributes: nil).string

        return decoded ?? self
    }
}
