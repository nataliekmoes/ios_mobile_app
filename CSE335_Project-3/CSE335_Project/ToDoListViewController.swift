//
//  ToDoListViewController.swift
//  CSE335_Project
//


import UIKit
import GoogleSignIn

class ToDoListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Initialization
    @IBOutlet weak var selectList: UIButton!
    @IBOutlet weak var taskListPhoto: UIButton!
    @IBOutlet weak var taskListTable: UITableView!
    
  
    var topLevelTasks = [TasksLoader.Task]()
    var allTasks = [TasksLoader.Task]()
    var taskLists = [TasksLoader.TaskList]()
    let tasksLoader = TasksLoader()
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var taskListImages: TaskListImages?
    var currentList: TasksLoader.TaskList?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskListImages = TaskListImages(context: managedObjectContext)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        // call API to get list of TaskLists
        tasksLoader.getTaskListsWithCompletion() { [self] lists in
            
            taskLists = lists
            currentList = taskLists[0]
            
            // instantiate TaskList menu
            var menuItems = [UIAction]()
            for tlist in taskLists {
                let t = UIAction(title: tlist.title!, handler: aHandler)
                menuItems.append(t)
            }
            
            // get tasks in current task list
            tasksLoader.getTasksWithCompletion(taskListId: currentList!.id!) { [self] tasks in
                allTasks = tasks
                topLevelTasks = tasksLoader.findTopLevelTasks(list: tasks)
                
                // update view
                DispatchQueue.main.sync() {
                    selectList.menu = UIMenu(title: "Task Lists", options: [.displayInline, .singleSelection], children: menuItems)
                    
                    let image = taskListImages?.getImage(listId: currentList!.id!, userId: GIDSignIn.sharedInstance.currentUser!.userID!)
                    taskListPhoto.setImage(UIImage(data: image!.image!), for: .normal)
                    
                    taskListTable.reloadData()  // reload table
                }
            }
        }
    }
    
    
    /// Change the displayed TaskList
    func aHandler(action: UIAction) {
        
        getCurrentList()
        
        if currentList != nil {
            tasksLoader.getTasksWithCompletion(taskListId: currentList!.id!) { [self] list in
                allTasks = list
                topLevelTasks = self.tasksLoader.findTopLevelTasks(list: list)
                
                DispatchQueue.main.sync {
                    if let image = self.taskListImages?.getImage(listId: currentList!.id!,
                                                                 userId: GIDSignIn.sharedInstance.currentUser!.userID!) {
                        taskListPhoto.setImage(UIImage(data: image.image!), for: .normal)
                    }
                    taskListTable.reloadData() // reload table
                }
            }
        }
        else {
            print("ToDoListViewController:aHandler Current TaskList is nil.")
        }
    }
    
    
    
    /// get currently selected list title and index in menu
    func getCurrentList() {
        
        var listTitle = selectList.menu?.selectedElements.first?.title
        var idx = 0
        
        for (i, l) in selectList.menu!.children.enumerated() {
            if l == selectList.menu?.selectedElements.first {
                listTitle = l.title
                idx = i
            }
        }
        print("Selected TaskList: (\(String(describing: listTitle)), \(idx))")
        currentList = tasksLoader.findTaskList(listTitle: listTitle!, listPosition: idx, taskLists: taskLists)
    }
    
    
    // MARK: Image handling
    
    @IBAction func choosePhoto(_ sender: Any) {
        
        let alert = UIAlertController(title: "Choose Photo", message: nil, preferredStyle: .actionSheet)
        let picker = UIImagePickerController()
        picker.delegate = self
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { action in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        })
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { action in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.allowsEditing = false
                picker.sourceType = UIImagePickerController.SourceType.camera
                picker.cameraCaptureMode = .photo
                picker.modalPresentationStyle = .fullScreen
                self.present(picker,animated: true,completion: nil)
            }
            else { print("No camera") }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        self.taskListImages?.saveContext()
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker .dismiss(animated: true, completion: nil)
        
        // get userId, current taskListId, taskList image entity, and chosen image
        if let listId = currentList?.id,
           let userId = GIDSignIn.sharedInstance.currentUser?.userID,
           let img = taskListImages?.getImage(listId: listId, userId: userId),
           let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            taskListPhoto.setImage(image, for: .normal)
            img.image = image.pngData()! as Data
            taskListImages?.saveContext()
        }
        else {
            print("ToDoListViewController:imagePickerController failed to process image.")
        }
    }
    
    
    // MARK: Addition
    
    
    @IBAction func addTask(_ sender: Any) {
       
        let alert = UIAlertController(title: "Add New Task", message: nil, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { textField in textField.placeholder = "title" } )
        
        alert.addAction(UIAlertAction(title: "Add", style: .default) { action in
            if let title = alert.textFields?.first?.text {
              
                // call create taskList API
                self.tasksLoader.insertTaskWithCompletion(taskTitle: title, taskListId: self.currentList!.id!) { task in
                    print(task)
                    self.allTasks.append(task)
                    self.topLevelTasks.append(task)
                    
                    DispatchQueue.main.sync {
                        self.taskListTable.reloadData()
                    }
                }
            }
        })
       
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
      
    }
    
    
    // MARK: DataSource and Delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // number of top-level tasks in this list
        return topLevelTasks.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        cell.layer.borderWidth = 0.5
        
        cell.taskTitle.text = topLevelTasks[indexPath.row].title
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete
        {
            let task = topLevelTasks[indexPath.row]
      
            // call api to delete task
            tasksLoader.deleteTaskWithCompletion(taskId: task.id!, taskListId: currentList!.id!) {
                
                // remove the selected task from both list of top level tasks and all tasks
                self.topLevelTasks.remove(at: indexPath.row)
                
                for t in 0..<self.allTasks.count-1 {
                    if self.allTasks[t].id == task.id {
                        self.allTasks.remove(at: t)
                    }
                }
                DispatchQueue.main.sync {
                    self.taskListTable.reloadData()
                
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true  }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle { return UITableViewCell.EditingStyle.delete }
    
    
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let selectedIndex: IndexPath = self.taskListTable.indexPath(for: sender as! UITableViewCell)!
        
        let task = topLevelTasks[selectedIndex.row]  // the selected task
        let subtasks = tasksLoader.findSubtasks(parentId: task.id!, tasks: allTasks)    // get child tasks of this task
        
        if(segue.identifier == "subtasks"){
            if let taskViewController: TaskViewController = segue.destination as? TaskViewController {
                taskViewController.tasksLoader = tasksLoader
                taskViewController.parentTask = task
                
                taskViewController.subtasks = subtasks
                taskViewController.allTasks = allTasks
                taskViewController.currentList = currentList
            }
        }
    }
    
    
}
