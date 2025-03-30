# 📌 To-Do List iOS Application  
This project showcases fundamental iOS features, including CoreData, Camera/Photo Library, MapKit, and web API integration, all implemented using the Model-View-Controller (MVC) architecture.  

## 📖 Description

<img src="https://user-images.githubusercontent.com/107507852/175116424-398495ba-43f8-4ea0-bb88-4ab87120095d.png" align="right" width="226" height="464">

This app allows users to:  
- View and manage their **Google Task Lists**  
- Associate images with Task Lists using the **Camera/Photo Library**  
- Interact with a **dynamic map** for location-based features

Users must sign in with their **Google account** and link it to the app to access all functionalities. Upon successful authentication, a **tabbed interface** is displayed with three main sections:  
1. **Account** – Manage user profile details  
2. **To-Do List** – View and organize tasks  
3. **Map** – Explore location-based features  

🔹 **Note:** Only registered **test Google accounts** can be linked, restricting full access to authorized testers.  

<br/><br/><br/>

## 🚀 Features  

### 🔑 **Account**  
✔ View **Google profile** details (name, email, profile image)  
✔ **Sign out** of Google and the app  
✔ **Disconnect** linked Google account  

### ✅ **To-Do List**  
✔ View **Google Task Lists**, Tasks, and Subtasks  
✔ **Add/Remove** Tasks and Subtasks  
✔ Attach an image to a Task List using **Camera/Photo Library** (stored in CoreData)  

### 🗺 **Map**  
✔ View and interact with a **dynamic map** (opens at the user's current location)  
✔ **Search for nearby places** and display them on the map  

## 🔗 External Packages & Web Services  
- **[GoogleSignIn](https://github.com/google/GoogleSignIn-iOS/)** – User authentication via Google  
- **[Google Tasks API (REST)](https://developers.google.com/tasks/reference/rest)** – Fetch and manage task data  
