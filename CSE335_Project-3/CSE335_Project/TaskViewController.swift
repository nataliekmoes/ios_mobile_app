//
//  TaskViewController.swift
//  CSE335_Project
//


import UIKit


class TaskViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Initialization
    
    @IBOutlet weak var parentTaskLbl: UILabel!
    @IBOutlet weak var subtaskTable: UITableView!
    
    var tasksLoader: TasksLoader?
    var parentTask: TasksLoader.Task?
    var subtasks = [TasksLoader.Task]()
    var allTasks = [TasksLoader.Task]()
    var currentList: TasksLoader.TaskList?
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        parentTaskLbl.text = parentTask?.title
        self.subtaskTable.reloadData()
        
    }
    
    
    // MARK: Addition
    @IBAction func addSubtask(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add New Subtask", message: nil, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { textField in textField.placeholder = "title" } )
        
        alert.addAction(UIAlertAction(title: "Add", style: .default) { action in
            if let title = alert.textFields?.first?.text {
             
                // call create taskList API
                self.tasksLoader?.insertChildTaskWithCompletion(taskTitle: title, parentTaskId: self.parentTask!.id!, taskListId: self.currentList!.id!) { task in
                    print(task)
                    self.allTasks.append(task)
                    self.subtasks.append(task)
                    DispatchQueue.main.sync {
                        self.subtaskTable.reloadData()
                    }
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    
    // MARK: DataSource and Delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subtasks.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        cell.layer.borderWidth = 0.5
        
        cell.taskTitle.text = subtasks[indexPath.row].title
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete
        {
            let subtask = subtasks[indexPath.row]
            
            // call api to delete task
            tasksLoader?.deleteTaskWithCompletion(taskId: subtask.id!, taskListId: currentList!.id!) {
                
                // remove the selected task from both list of top level tasks and all tasks
                self.subtasks.remove(at: indexPath.row)
                
                for t in 0..<self.allTasks.count-1 {
                    if self.allTasks[t].id == subtask.id {
                        self.allTasks.remove(at: t)
                    }
                }
                DispatchQueue.main.sync {
                    self.subtaskTable.reloadData()
                }
            }
        }
    }
    
    
}
