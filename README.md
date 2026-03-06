# music_library

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

### 1. Using Equatable for Model and State Comparison and Ui 

Is project model me maine Equatable package use kiya hai taaki objects ki value based comparison easily ho sake.
and library screen ki list baana di hai.

## 2. api service and connectivity plus 

http and connectivity plus package ka use kiye hain 
http ka api call and internet band hone pe message show karne ke liye connectivity plus ka
NoInternetException custom exeption banaya jo ki agar internet close ho jaat hai to screen pe message show karegi. 
 try catch ke throgh error ko handle kiye hain and track details screen banayena haian 
 

## 3. search by name and number (track reporsitory)
issue:  Search karte waqt bhi pagination scroll listener se call ho raha tha jisse unwanted tracks list me add ho rahe the.

fix:  isSearching boolean flag add kiya taaki search mode me pagination disable rahe.






A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
