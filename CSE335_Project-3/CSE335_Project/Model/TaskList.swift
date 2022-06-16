//
//  TaskList.swift
//  CSE335_Project
//
//  API reference:  https://developers.google.com/tasks


import Foundation
import GoogleSignIn


class TasksLoader {
    
    // MARK: Structs
    
    struct TaskLists : Codable {
        var items: [TaskList]
    }
    
    struct TaskList: Codable {
        var id: String?
        var title: String?
    }
    
    struct Tasks: Codable {
        var items: [Task]
    }
    
    struct Task: Codable {
        var id: String?
        var title: String?
        var selfLink: String?
        var parent: String?     // task id of parent task
        var position: String?
    }
    
    
    
    var urlSession: URLSession? = {
        guard let accessToken = GIDSignIn.sharedInstance.currentUser?.authentication.accessToken else { return nil }
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        return URLSession(configuration: configuration)
    }()
    
    
    
    // MARK: - Get
    
    func getTaskListsWithCompletion(completion: @escaping ([TaskList]) -> ()) {
        
        let url = URL(string: "https://www.googleapis.com/tasks/v1/users/@me/lists")!
        
        let _ = urlSession?.dataTask(with: url) { data, response, error in
            if let data = data {
                if let taskLists = try? JSONDecoder().decode(TaskLists.self, from: data) {
                    completion(taskLists.items)
                }
                else {
                    print("Invalid HTTP Response:\n \(String(describing: response?.debugDescription))")
                }
            }
            else if let error = error {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    
    func getTaskListWithCompletion(taskListId: String, completion: @escaping (TaskList) -> ()) {
        
        let url = URL(string: "https://www.googleapis.com/tasks/v1/users/@me/lists/\(taskListId)")!
        
        let _ = urlSession?.dataTask(with: url) { data, response, error in
            if let data = data {
                if let taskList = try? JSONDecoder().decode(TaskList.self, from: data) {
                    completion(taskList)
                }
                else {
                    print("Invalid HTTP Response: \n\(String(describing: response?.debugDescription))")
                }
            }
            else if let error = error {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    
    func getTasksWithCompletion(taskListId: String, completion: @escaping ([TasksLoader.Task]) -> ()) {
        
        let url = URL(string: "https://www.googleapis.com/tasks/v1/lists/\(taskListId)/tasks")!
        
        let _ = urlSession?.dataTask(with: url) { data, response, error in
            if let data = data {
                if let tasks = try? JSONDecoder().decode(Tasks.self, from: data) {
                    completion(tasks.items)
                }
                else {
                    print("Invalid HTTP Response: \n\(String(describing: response?.debugDescription))")
                }
            }
            else if let error = error {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    
    func getTaskWithCompletion(taskListId: String, taskId: String, completion: @escaping (TasksLoader.Task) -> ()) {
        
        let url = URL(string: "https://www.googleapis.com/tasks/v1/lists/\(taskListId)/tasks/\(taskId)")!
        
        let _ = urlSession?.dataTask(with: url) { data, response, error in
            if let data = data {
                if let task = try? JSONDecoder().decode(TasksLoader.Task.self, from: data) {
                    completion(task)
                }
                else {
                    print("Invalid HTTP Response: \n\(String(describing: response?.debugDescription))")
                }
            }
            else if let error = error {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    
    // MARK: - Insertion
    
    func insertTaskListWithCompletion(taskListTitle:String, completion: @escaping (TaskList) -> ()) {
        
        let list = TaskList(title: taskListTitle)
        let JSONData = try? JSONEncoder().encode(list)
        
        var request = URLRequest(url: URL(string: "https://www.googleapis.com/tasks/v1/users/@me/lists")!)
        request.httpMethod = "POST"
        request.httpBody = JSONData
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let _ = urlSession?.dataTask(with: request) { data, response, error in
            if let data = data {
                if let taskList = try? JSONDecoder().decode(TaskList.self, from: data) {
                    //print(taskList)
                    completion(taskList)
                }
                else {
                    print("Invalid HTTP Response: \n\(String(describing: response?.debugDescription))")
                }
            }
            else if let error = error {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    
    func insertTaskWithCompletion(taskTitle: String, taskListId: String, completion: @escaping (TasksLoader.Task) -> ()) {
        
        let task = TasksLoader.Task(title: taskTitle)
        let JSONData = try? JSONEncoder().encode(task)
        
        var request = URLRequest(url: URL(string: "https://www.googleapis.com/tasks/v1/lists/\(taskListId)/tasks")!)
        request.httpMethod = "POST"
        request.httpBody = JSONData
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let _ = urlSession?.dataTask(with: request) { data, response, error in
            if let data = data {
                if let task = try? JSONDecoder().decode(TasksLoader.Task.self, from: data) {
                    completion(task)
                }
                else {
                    print("Invalid HTTP Response: \n\(String(describing: response?.debugDescription))")
                }
            }
            else if let error = error {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    
    
    func insertChildTaskWithCompletion(taskTitle: String, parentTaskId: String, taskListId: String, completion: @escaping (TasksLoader.Task) -> ()) {
        
        let task = TasksLoader.Task(title: taskTitle, parent: parentTaskId)
        let JSONData = try? JSONEncoder().encode(task)
        
        var urlComp = URLComponents(string: "https://www.googleapis.com/tasks/v1/lists/\(taskListId)/tasks")
        urlComp?.queryItems = [URLQueryItem(name: "parent", value: parentTaskId)]
        
        var request = URLRequest(url: (urlComp?.url)!)
        request.httpMethod = "POST"
        request.httpBody = JSONData
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let _ = urlSession?.dataTask(with: request) { data, response, error in
            if let data = data {
                if let task = try? JSONDecoder().decode(TasksLoader.Task.self, from: data) {
                    completion(task)
                }
                else {
                    print("Invalid HTTP Response: \n\(String(describing: response?.debugDescription))")
                }
            }
            else if let error = error {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    
    
    // MARK: - Deletion
    
    func deleteTaskListWithCompletion(taskListId: String, completion: @escaping () -> ()) {
        
        var request = URLRequest(url: URL(string: "https://www.googleapis.com/tasks/v1/users/@me/lists/\(taskListId)")!)
        request.httpMethod = "DELETE"
        
        let _ = urlSession?.dataTask(with: request) { data, response, error in
            if data != nil {
                //print("Response: \n\(response.debugDescription)")
            }
            else if let error = error {
                print(error.localizedDescription)
            }
            completion()
        }.resume()
    }
    
    
    func deleteTaskWithCompletion(taskId: String, taskListId: String, completion: @escaping () -> ()) {
        
        var request = URLRequest(url: URL(string: "https://www.googleapis.com/tasks/v1/lists/\(taskListId)/tasks/\(taskId)")!)
        request.httpMethod = "DELETE"
        
        let _ = urlSession?.dataTask(with: request) { data, response, error in
            if data != nil {
                //print("Response: \n\(response.debugDescription)")
            }
            else if let error = error {
                print(error.localizedDescription)
            }
            completion()
        }.resume()
    }
    
    
    
    // MARK: - Helpers
    
    func findTopLevelTasks(list: [TasksLoader.Task]) -> [TasksLoader.Task] {
        var topLvlTasks = [TasksLoader.Task]()
        
        for task in list {
            if task.parent == nil {
                topLvlTasks.insert(task, at: 0)
            }
        }
        
        return topLvlTasks
    }
    
    
    func findSubtasks(parentId: String, tasks: [TasksLoader.Task]) -> [TasksLoader.Task] {
        var subtasks = [TasksLoader.Task]()
        
        for task in tasks {
            if task.parent == parentId {
                subtasks.insert(task, at: 0)
            }
        }
        
        return subtasks
    }
    
    
    func findTaskList(listTitle: String, listPosition: Int, taskLists: [TaskList]) -> TaskList? {
        var matching: TaskList?
        
        for (i, tList) in taskLists.enumerated() {
            if tList.title == listTitle  && i == listPosition {
                matching = tList
            }
        }
        
        return matching
    }
    
    
}


