//
//  CoreDataManager.swift
//  RecreateSpotify
//
//  Created by George Maximillian Theodore on 04/09/26.
//

import CoreData
import Foundation

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "RecreateSpotify")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func saveTrack(id:String, title: String, artist: String, duration: String, imageUrl: String) {
        let trackEntity = TrackEntity(context: context)
        trackEntity.id = id
        trackEntity.title = title
        trackEntity.artists = artist
        trackEntity.duration = duration
        trackEntity.imageUrl = imageUrl
        
        saveContext()
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .didUpdateSavedTracks, object: nil)
        }
    }
    
    func fetchTracks() -> [TrackEntity] {
        let request: NSFetchRequest<TrackEntity> = TrackEntity.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    func isSavedTrack(id: String) -> Bool {
        let request: NSFetchRequest<TrackEntity> = TrackEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            return false
        }
    }
    
    func deleteTrack(id: String) {
        let request: NSFetchRequest<TrackEntity> = TrackEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let results = try context.fetch(request)
            for entity in results {
                context.delete(entity)
            }
            saveContext()
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .didUpdateSavedTracks, object: nil)
            }
        } catch {
            print("Error deleting track: \(error.localizedDescription)")
        }
    }

}
