//
//  SettingsViewController.swift
//  Ryu
//
//  Created by Francesco on 22/06/24.
//

import UIKit
import UniformTypeIdentifiers

class SettingsViewController: UITableViewController {
    
    @IBOutlet var autoPlaySwitch: UISwitch!
    @IBOutlet var landScapeSwitch: UISwitch!
    @IBOutlet var browserPlayerSwitch: UISwitch!
    @IBOutlet var mergeActivitySwitch: UISwitch!
    @IBOutlet var FavoriteNotificationSwitch: UISwitch!
    @IBOutlet var syncThemeSwitch: UISwitch!
    
    @IBOutlet weak var playerButton: UIButton!
    @IBOutlet weak var sourceButton: UIButton!
    
    @IBOutlet weak var episodeSortingSegmentedControl: UISegmentedControl!
    @IBOutlet weak var themeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var holdSpeedSteppper: UIStepper!
    @IBOutlet weak var holdSpeeedLabel: UILabel!
    
    let githubURL = "https://github.com/cranci1/Ryu/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHoldSpeedStepper()
        setupThemeControls()
        loadUserDefaults()
        setupMenu()
        
        if let selectedOption = UserDefaults.standard.string(forKey: "selectedMediaSource") {
            sourceButton.setTitle(selectedOption, for: .normal)
        }
        
        let isReverseSorted = UserDefaults.standard.bool(forKey: "isEpisodeReverseSorted")
        episodeSortingSegmentedControl.selectedSegmentIndex = isReverseSorted ? 1 : 0
    }
    
    private func setupThemeControls() {
        let syncWithSystem = UserDefaults.standard.bool(forKey: "syncWithSystem")
        syncThemeSwitch.isOn = syncWithSystem
        
        themeSegmentedControl.removeAllSegments()
        themeSegmentedControl.insertSegment(withTitle: "Dark", at: 0, animated: false)
        themeSegmentedControl.insertSegment(withTitle: "Light", at: 1, animated: false)
        
        let selectedTheme = UserDefaults.standard.integer(forKey: "selectedTheme")
        themeSegmentedControl.selectedSegmentIndex = selectedTheme
        
        themeSegmentedControl.isEnabled = !syncWithSystem
    }
    
    @IBAction func syncThemeSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "syncWithSystem")
        themeSegmentedControl.isEnabled = !sender.isOn
        updateAppAppearance()
    }
    
    @IBAction func themeSegmentedControlChanged(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "selectedTheme")
        updateAppAppearance()
    }
    
    private func updateAppAppearance() {
        let syncWithSystem = UserDefaults.standard.bool(forKey: "syncWithSystem")
        
        if syncWithSystem {
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .unspecified
            }
        } else {
            let selectedTheme = UserDefaults.standard.integer(forKey: "selectedTheme")
            switch selectedTheme {
            case 0:
                UIApplication.shared.windows.forEach { window in
                    window.overrideUserInterfaceStyle = .dark
                }
            case 1:
                UIApplication.shared.windows.forEach { window in
                    window.overrideUserInterfaceStyle = .light
                }
            default:
                UIApplication.shared.windows.forEach { window in
                    window.overrideUserInterfaceStyle = .unspecified
                }
            }
        }
    }
    
    private func setupHoldSpeedStepper() {
        let holdSpeed = UserDefaults.standard.float(forKey: "holdSpeedPlayer")
        holdSpeedSteppper.value = Double(holdSpeed)
        holdSpeedSteppper.minimumValue = 0.50
        holdSpeedSteppper.maximumValue = 2.0
        holdSpeedSteppper.stepValue = 0.25
        updateHoldSpeedLabel()
    }
    
    @IBAction func holdSpeedStepperValueChanged(_ sender: UIStepper) {
        let holdSpeed = Float(sender.value)
        UserDefaults.standard.set(holdSpeed, forKey: "holdSpeedPlayer")
        updateHoldSpeedLabel()
    }
    
    private func updateHoldSpeedLabel() {
        let holdSpeeed = UserDefaults.standard.float(forKey: "holdSpeedPlayer")
        holdSpeeedLabel.text = String(format: "Hold Speed player: %.2fx", holdSpeeed)
    }
    
    @IBAction func episodeSortingChanged(_ sender: UISegmentedControl) {
        let isReverseSorted = sender.selectedSegmentIndex == 1
        UserDefaults.standard.set(isReverseSorted, forKey: "isEpisodeReverseSorted")
    }
    
    @IBAction func githubTapped(_ sender: UITapGestureRecognizer) {
        openURL(githubURL)
    }
    
    func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func selectSourceButtonTapped(_ sender: UIButton) {
        SourceMenu.showSourceSelector(from: self, sourceView: sender) { [weak self] in
            self?.updateSourceButtonTitle()
        }
    }
    
    private func updateSourceButtonTitle() {
        if let selectedSourceRawValue = UserDefaults.standard.string(forKey: "selectedMediaSource"),
           let selectedSource = MediaSource(rawValue: selectedSourceRawValue) {
            sourceButton.setTitle(selectedSource.displayName, for: .normal)
        } else {
            sourceButton.setTitle("Select Source", for: .normal)
        }
    }
    
    func setupMenu() {
        let defaultIcon = UIImage(systemName: "play.rectangle.fill")
        let infuseIcon = UIImage(systemName: "flame")
        let vlcIcon = UIImage(systemName: "film")
        let outplayerIcon = UIImage(systemName: "play.circle.fill")
        let customIcon = UIImage(systemName: "bolt.horizontal.fill")
        let networkIcon = UIImage(systemName: "network")
        let nPlayerIcon = UIImage(systemName: "play.fill")
        
        let action1 = UIAction(title: "Default", image: defaultIcon, handler: { [weak self] _ in
            UserDefaults.standard.set("Default", forKey: "mediaPlayerSelected")
            self?.playerButton.setTitle("Default", for: .normal)
        })
        let action2 = UIAction(title: "VLC", image: vlcIcon, handler: { [weak self] _ in
            UserDefaults.standard.set("VLC", forKey: "mediaPlayerSelected")
            self?.playerButton.setTitle("VLC", for: .normal)
        })
        let action3 = UIAction(title: "Infuse", image: infuseIcon, handler: { [weak self] _ in
            UserDefaults.standard.set("Infuse", forKey: "mediaPlayerSelected")
            self?.playerButton.setTitle("Infuse", for: .normal)
        })
        let action4 = UIAction(title: "OutPlayer", image: outplayerIcon, handler: { [weak self] _ in
            UserDefaults.standard.set("OutPlayer", forKey: "mediaPlayerSelected")
            self?.playerButton.setTitle("OutPlayer", for: .normal)
        })
        let action7 = UIAction(title: "nPlayer", image: nPlayerIcon, handler: { [weak self] _ in
            UserDefaults.standard.set("nPlayer", forKey: "mediaPlayerSelected")
            self?.playerButton.setTitle("nPlayer", for: .normal)
        })
        let action5 = UIAction(title: "Custom", image: customIcon, handler: { [weak self] _ in
            UserDefaults.standard.set("Custom", forKey: "mediaPlayerSelected")
            self?.playerButton.setTitle("Custom", for: .normal)
        })
        let action6 = UIAction(title: "WebPlayer", image: networkIcon, handler: { [weak self] _ in
            UserDefaults.standard.set("WebPlayer", forKey: "mediaPlayerSelected")
            self?.playerButton.setTitle("WebPlayer", for: .normal)
        })
        
        let menu = UIMenu(title: "Select Media Player", children: [action1, action2, action3, action4, action7, action5])
        
        playerButton.menu = menu
        playerButton.showsMenuAsPrimaryAction = true
        
        if let selectedOption = UserDefaults.standard.string(forKey: "mediaPlayerSelected") {
            playerButton.setTitle(selectedOption, for: .normal)
        }
    }
    
    @IBAction func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    private func loadUserDefaults() {
        autoPlaySwitch.isOn = UserDefaults.standard.bool(forKey: "AutoPlay")
        landScapeSwitch.isOn = UserDefaults.standard.bool(forKey: "AlwaysLandscape")
        browserPlayerSwitch.isOn = UserDefaults.standard.bool(forKey: "browserPlayer")
        mergeActivitySwitch.isOn = UserDefaults.standard.bool(forKey: "mergeWatching")
        FavoriteNotificationSwitch.isOn = UserDefaults.standard.bool(forKey: "notificationEpisodes")
        
        let holdSpeeed = UserDefaults.standard.float(forKey: "holdSpeedPlayer")
        holdSpeeedLabel.text = String(format: "Hold Speed player: %.2fx", holdSpeeed)
        
        let syncWithSystem = UserDefaults.standard.bool(forKey: "syncWithSystem")
        syncThemeSwitch.isOn = syncWithSystem
        
        let selectedTheme = UserDefaults.standard.integer(forKey: "selectedTheme")
        themeSegmentedControl.selectedSegmentIndex = selectedTheme
        themeSegmentedControl.isEnabled = !syncWithSystem
    }
    
    @IBAction func clearCache(_ sender: Any) {
        clearCache()
    }
    
    @IBAction func autpPlayToggle(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "AutoPlay")
    }
    
    @IBAction func landScapeToggle(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "AlwaysLandscape")
    }
    
    @IBAction func browserPlayerToggle(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "browserPlayer")
    }
    
    @IBAction func mergeActivtyToggle(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "mergeWatching")
    }
    
    @IBAction func notificationsToggle(_ sender: UISwitch) {
        if sender.isOn {
            requestNotificationPermissions { granted in
                DispatchQueue.main.async {
                    if granted {
                        UserDefaults.standard.set(true, forKey: "notificationEpisodes")
                    } else {
                        sender.setOn(false, animated: true)
                        UserDefaults.standard.set(false, forKey: "notificationEpisodes")
                    }
                }
            }
        } else {
            UserDefaults.standard.set(false, forKey: "notificationEpisodes")
        }
    }

    private func requestNotificationPermissions(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permissions: \(error)")
                completion(false)
            } else {
                completion(granted)
            }
        }
    }
    
    @IBAction func createBackup(_ sender: Any) {
        guard let backupString = BackupManager.shared.createBackup() else {
            showAlert(message: "Failed to create backup.")
            return
        }
        saveBackupToTemporaryDirectory(backupString, sender: sender)
    }
    
    @IBAction private func importBackupTapped(_ sender: Any) {
        presentDocumentPicker()
    }
    
    @IBAction private func resetAppTapped(_ sender: Any) {
        presentResetConfirmation()
    }
    
    @IBAction func clearSearchHistory(_ sender: Any) {
        clearSearchHistory()
    }
    
    private func clearSearchHistory() {
        UserDefaults.standard.removeObject(forKey: "SearchHistory")
        showAlert(message: "Search history cleared successfully!")
    }
    
    private func clearCache() {
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        
        do {
            if let cacheURL = cacheURL {
                let filePaths = try FileManager.default.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: nil, options: [])
                for filePath in filePaths {
                    try FileManager.default.removeItem(at: filePath)
                }
                showAlert(message: "Cache cleared successfully!")
            }
        } catch {
            print("Could not clear cache: \(error)")
            showAlert(message: "Failed to clear cache.")
        }
    }
    
    private func showAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func saveBackupToTemporaryDirectory(_ backupString: String, sender: Any) {
        let backupData = Data(backupString.utf8)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd_MMMM_yyyy-HHmm"
        let dateString = dateFormatter.string(from: Date())
        let fileName = "\(dateString).albackup"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try backupData.write(to: tempURL)
            presentActivityViewController(with: tempURL, sender: sender)
        } catch {
            showAlert(message: "Failed to save backup: \(error.localizedDescription)")
        }
    }
    
    private func presentActivityViewController(with url: URL, sender: Any) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityVC.excludedActivityTypes = [.addToReadingList, .assignToContact, .markupAsPDF]
        
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = sender as? UIView ?? view
            popoverController.sourceRect = (sender as? UIView)?.bounds ?? view.bounds
        }
        
        present(activityVC, animated: true, completion: nil)
    }
    
    private func presentDocumentPicker() {
        let documentPicker: UIDocumentPickerViewController
        documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType("me.cranci.albackup")!], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
    private func presentResetConfirmation() {
        let alertController = UIAlertController(title: "Reset App Data", message: "Are you sure you want to reset all app Data? This action cannot be undone.", preferredStyle: .alert)
        
        let resetAction = UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            self?.resetUserDefaults()
            self?.loadUserDefaults()
            self?.showAlert(message: "App Data have been reset.")
        }
        
        alertController.addAction(resetAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func resetUserDefaults() {
        if let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
            
            NotificationCenter.default.post(name: .appDataReset, object: nil)
        }
    }
    
    @IBAction func deleteAllDonloads(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to delete all downloads? This action cannot be undone.", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.performDeletion()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func performDeletion() {
        let fileManager = FileManager.default
        do {
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            
            for fileURL in fileURLs {
                try fileManager.removeItem(at: fileURL)
            }
            
            showAlert(message: "All Downloads have been deleted successfully.")
        } catch {
            showAlert(message: "Failed to delete all downloads: \(error.localizedDescription)")
        }
    }
}

extension SettingsViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else {
            showAlert(message: "No file selected.")
            return
        }
        
        presentBackupImportOptions(for: selectedFileURL)
    }
    
    private func presentBackupImportOptions(for url: URL) {
        let alertController = UIAlertController(title: "Backup Import Options", message: "Choose how to handle the backup:", preferredStyle: .alert)
        
        let replaceAction = UIAlertAction(title: "Replace Current Data", style: .default) { [weak self] _ in
            self?.replaceData(withBackupAt: url)
        }
        
        let mergeAction = UIAlertAction(title: "Merge Backup with Data", style: .default) { [weak self] _ in
            self?.mergeBackup(withBackupAt: url)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(replaceAction)
        alertController.addAction(mergeAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func replaceData(withBackupAt url: URL) {
        do {
            
            if let domain = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: domain)
                UserDefaults.standard.synchronize()
            }
            
            let backupData = try Data(contentsOf: url)
            guard let backupString = String(data: backupData, encoding: .utf8) else {
                showAlert(message: "Invalid backup file format.")
                return
            }
            
            if BackupManager.shared.importBackup(backupString) {
                showAlert(message: "Backup imported successfully and current data replaced!")
                NotificationCenter.default.post(name: .appDataReset, object: nil)
                loadUserDefaults()
            } else {
                showAlert(message: "Failed to import backup.")
            }
        } catch {
            showAlert(message: "Failed to read backup file: \(error.localizedDescription)")
        }
    }
    
    private func mergeBackup(withBackupAt url: URL) {
        do {
            let backupData = try Data(contentsOf: url)
            guard let backupString = String(data: backupData, encoding: .utf8) else {
                showAlert(message: "Invalid backup file format.")
                return
            }
            
            if BackupManager.shared.importBackup(backupString) {
                showAlert(message: "Backup imported successfully and merged with current data!")
                NotificationCenter.default.post(name: .appDataReset, object: nil)
                loadUserDefaults()
            } else {
                showAlert(message: "Failed to import backup.")
            }
        } catch {
            showAlert(message: "Failed to read backup file: \(error.localizedDescription)")
        }
    }
}
