# To-do List iOS Application
Showcases fundamental iOS application features, including the use of CoreData, Camera/Photo Library, MapKit, and web APIs and uses MVC (Model-View-Controller) Architecture.

## Description

Offers users the ability to view and manage their Google Task Lists, associate an image with a Task List, and interact with a dynamic map. Users must sign in to their Google account and link it to the app before gaining access to the full app. Upon successful sign-in, a tab view is displayed containing three tabs: **Account**, **To-do List**, and **Map**. 

**NOTE:** Only registered Google accounts for testing can be linked, preventing access to the full app.  
## Features
<img align="right" src="https://user-images.githubusercontent.com/107507852/175116424-398495ba-43f8-4ea0-bb88-4ab87120095d.png">

### Account
- View Google profile name, email, and profile image
- Sign out of Google account and app 
- Disconnect linked Google account

### To-do List
- View Google Task Lists, Tasks, and Subtasks
- Add/Remove Tasks and Subtasks
- Choose an image from Camera/Photo Library to display with a Task List (stored in CoreData)

### Map
- View and interact with a dynamic map (opens showing current location)
- Search for nearby places and view them on the map

<br/>

## External Packages & Web Services
- [GoogleSignIn](https://github.com/google/GoogleSignIn-iOS/)
- [Google Tasks API (REST)](https://developers.google.com/tasks/reference/rest) 
