//
//  AnimeInformation.swift
//  AnimeLounge
//
//  Created by Francesco on 22/06/24.
//

import UIKit
import Kingfisher

class AnimeInformation: UITableViewController {
    
    var animeID: Int = 0
    var animeData: [String: Any]?
    
    private let coverImageView = UIImageView()
    private let bannerImageView = UIImageView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchAnimeData()
    }
    
    private func setupUI() {
        tableView.backgroundColor = UIColor.secondarySystemBackground
        tableView.register(AnimeInfoCell.self, forCellReuseIdentifier: "AnimeInfoCell")
        tableView.register(AnimeCharacterCell.self, forCellReuseIdentifier: "AnimeCharacterCell")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        
        setupHeaderView()
        setupLoadingIndicator()
    }
    
    private func setupHeaderView() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 250))
        
        headerView.addSubview(bannerImageView)
        headerView.addSubview(coverImageView)
        
        bannerImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bannerImageView.topAnchor.constraint(equalTo: headerView.topAnchor),
            bannerImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            bannerImageView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            bannerImageView.heightAnchor.constraint(equalToConstant: 150),
            
            coverImageView.topAnchor.constraint(equalTo: bannerImageView.bottomAnchor, constant: -50),
            coverImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            coverImageView.widthAnchor.constraint(equalToConstant: 100),
            coverImageView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        coverImageView.layer.cornerRadius = 8
        coverImageView.clipsToBounds = true
        coverImageView.contentMode = .scaleAspectFill
        bannerImageView.contentMode = .scaleAspectFill
        
        tableView.tableHeaderView = headerView
    }
    
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.center = view.center
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
    }
    
    private func fetchAnimeData() {
        AnimeService.fetchAnimeDetails(animeID: animeID) { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                
                switch result {
                case .success(let animeData):
                    self?.animeData = animeData
                    self?.updateUI()
                case .failure(let error):
                    self?.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func updateUI() {
        guard let animeData = animeData else { return }
        
        if let title = (animeData["title"] as? [String: String])?["romaji"] {
            self.title = title
        }
        
        if let coverImage = (animeData["coverImage"] as? [String: String])?["large"],
           let coverImageUrl = URL(string: coverImage) {
            coverImageView.kf.setImage(with: coverImageUrl)
        }
        
        if let bannerImage = animeData["bannerImage"] as? String,
           let bannerImageUrl = URL(string: bannerImage) {
            bannerImageView.kf.setImage(with: bannerImageUrl)
        }
        
        tableView.reloadData()
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if let characters = animeData?["characters"] as? [String: Any],
               let edges = characters["edges"] as? [[String: Any]] {
                return edges.count
            }
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AnimeInfoCell", for: indexPath) as! AnimeInfoCell
            cell.configure(with: animeData)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AnimeCharacterCell", for: indexPath) as! AnimeCharacterCell
            if let characters = animeData?["characters"] as? [String: Any],
               let edges = characters["edges"] as? [[String: Any]] {
                cell.configure(with: edges[indexPath.row])
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Anime Information" : "Characters"
    }
}

class AnimeInfoCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let genresLabel = UILabel()
    private let scoreLabel = UILabel()
    private let episodesLabel = UILabel()
    private let statusLabel = UILabel()
    private let datesLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel, descriptionLabel, genresLabel,
            scoreLabel, episodesLabel, statusLabel, datesLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        descriptionLabel.numberOfLines = 0
        genresLabel.font = UIFont.italicSystemFont(ofSize: 14)
        [scoreLabel, episodesLabel, statusLabel, datesLabel].forEach { $0.font = UIFont.systemFont(ofSize: 14) }
    }
    
    func configure(with animeData: [String: Any]?) {
        guard let animeData = animeData else { return }
        
        titleLabel.text = (animeData["title"] as? [String: String])?["romaji"]
        descriptionLabel.text = animeData["description"] as? String
        genresLabel.text = "Genres: " + ((animeData["genres"] as? [String])?.joined(separator: ", ") ?? "")
        scoreLabel.text = "Score: " + String(animeData["averageScore"] as? Int ?? 0)
        episodesLabel.text = "Episodes: " + String(animeData["episodes"] as? Int ?? 0)
        statusLabel.text = "Status: " + (animeData["status"] as? String ?? "N/A")
        
        if let startDate = animeData["startDate"] as? [String: Int],
           let endDate = animeData["endDate"] as? [String: Int] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let start = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(startDate["year"] ?? 0)))
            let end = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(endDate["year"] ?? 0)))
            datesLabel.text = "Aired: \(start) to \(end)"
        } else {
            datesLabel.text = "Aired: N/A"
        }
    }
}

class AnimeCharacterCell: UITableViewCell {
    private let characterImageView = UIImageView()
    private let nameLabel = UILabel()
    private let roleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        characterImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        roleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(characterImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(roleLabel)
        
        NSLayoutConstraint.activate([
            characterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            characterImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            characterImageView.widthAnchor.constraint(equalToConstant: 50),
            characterImageView.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.leadingAnchor.constraint(equalTo: characterImageView.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            roleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            roleLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            roleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        characterImageView.contentMode = .scaleAspectFill
        characterImageView.clipsToBounds = true
        characterImageView.layer.cornerRadius = 25
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        roleLabel.font = UIFont.systemFont(ofSize: 14)
        roleLabel.textColor = .gray
    }
    
    func configure(with character: [String: Any]) {
        if let node = character["node"] as? [String: Any],
           let name = node["name"] as? [String: String] {
            nameLabel.text = name["full"]
        }
        
        roleLabel.text = character["role"] as? String
        
        if let node = character["node"] as? [String: Any],
           let image = node["image"] as? [String: String],
           let imageUrlString = image["large"],
           let imageUrl = URL(string: imageUrlString) {
            characterImageView.kf.setImage(with: imageUrl, placeholder: UIImage(named: "character_placeholder"))
        }
    }
}

class AnimeService {
    static func fetchAnimeDetails(animeID: Int, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let query = """
        query {
          Media(id: \(animeID), type: ANIME) {
            id
            title {
              romaji
              english
              native
            }
            description(asHtml: false)
            coverImage {
              large
            }
            bannerImage
            averageScore
            genres
            episodes
            status
            startDate {
              year
              month
              day
            }
            endDate {
              year
              month
              day
            }
            characters {
              edges {
                role
                node {
                  id
                  name {
                    full
                  }
                  image {
                    large
                  }
                }
              }
            }
          }
        }
        """
        
        let apiUrl = URL(string: "https://graphql.anilist.co")!
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["query": query], options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "AnimeService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let data = json["data"] as? [String: Any],
                   let media = data["Media"] as? [String: Any] {
                    completion(.success(media))
                } else {
                    completion(.failure(NSError(domain: "AnimeService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
 