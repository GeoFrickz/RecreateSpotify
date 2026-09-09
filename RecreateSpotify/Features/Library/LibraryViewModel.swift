//
//  LibraryViewModel.swift
//  RecreateSpotify
//
//  Created by George Maximillian Theodore on 07/09/26.
//

import CoreData

class LibraryViewModel {
    
    var savedTracks: [TrackEntity] = []
    
    func fetchSavedTracks() {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<TrackEntity> = TrackEntity.fetchRequest()
        
        do {
            savedTracks = try context.fetch(fetchRequest)
        } catch {
            print("Error fetching tracks: \(error.localizedDescription)")
        }
    }
    
    func deleteTrack(at index: Int) {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<TrackEntity> = TrackEntity.fetchRequest()
        
        do {
            savedTracks = try context.fetch(fetchRequest)
            let trackToDelete = savedTracks[index]
            
            context.delete(trackToDelete)
            try context.save()
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .didUpdateSavedTracks, object: nil)
            }
        } catch {
            print("Error deleting track: \(error.localizedDescription)")
        }
    }
}
