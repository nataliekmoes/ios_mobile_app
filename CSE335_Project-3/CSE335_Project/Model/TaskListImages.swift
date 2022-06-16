//
//  User.swift
//  CSE335_Project
//


import UIKit
import CoreData


class TaskListImages {
    
    let managedObjectContext: NSManagedObjectContext?
    var images = [String : TaskListImage]()
    
    
    
    init(context: NSManagedObjectContext) {
        // Getting a handler to the coredata managed object context
        managedObjectContext = context
        images = fetchTaskListImages()
    }
    
    
    func getImage(listId: String, userId: String) -> TaskListImage? {
        if let img = images[listId], img.userId == userId {
            return img
        }
        else {
            addListImage(listId: listId, userId: userId)
            return images[listId]
        }
    }
    
    
    func addListImage(listId: String, userId: String) {
        // get a handler to the entity through the managed object context
        let ent = NSEntityDescription.entity(forEntityName: "TaskListImage", in: managedObjectContext!)
        
        // create an object instance
        let x = TaskListImage(entity: ent!, insertInto: managedObjectContext)
        x.userId = userId
        x.taskListId = listId
        x.image = UIImage(systemName: "photo.on.rectangle")?.pngData() 
        
        images[listId] = x
        
        saveContext()
    }
    
    
    func deleteListImage(listId: String) {
        guard let img = images[listId] else { return }
        managedObjectContext?.delete(img)
        images.removeValue(forKey: listId)
        saveContext()
    }
    
    
    func fetchTaskListImages() -> [String : TaskListImage] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskListImage")
        let result = ((try? managedObjectContext!.fetch(fetchRequest)) as! [TaskListImage])
        var imgs = [String : TaskListImage]()
        
        result.forEach { listImage in
            imgs[listImage.taskListId!] = listImage
        }
        return imgs
    }
    
    
    /// save the updated context
    func saveContext() {
        do { try managedObjectContext!.save() }
        catch  { print(error.localizedDescription) }
    }
    
    
    func clearData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskListImage")
        
        // performs the batch delete
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedObjectContext!.execute(deleteRequest)
            try managedObjectContext!.save()
        } catch { }
    }

}
