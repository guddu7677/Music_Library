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

### 4. Bloc library flow and issues /fixe

1. LibraryStarted
App start hone par LibraryStarted event trigger hota hai.  
Ye first page ke tracks API se load karta hai aur state ko loading  success me update karta hai.

2. LibraryLoadMoreRequested
Jab user list ko scroll karta hai to ye event trigger hota hai.  
Ye pagination handle karta hai aur next page ke tracks load karke existing list me merge karta hai.

3. LibrarySearchChanged
Jab user search bar me type karta hai to ye event fire hota hai.  
Pehle locally loaded tracks me filter karta hai aur phir debounce (500ms) ke baad API search call karta hai.

4. LibraryGroupByChanged
User tracks ko Title ya Artist ke basis par group kar sakta hai.  
Is event me tracks ko sort karke sticky header ke saath display kiya jata hai.


### Issues Faced & Fix

1. Multiple API Calls while Searching 
Issue: User fast type karta tha to API bar-bar hit ho rahi thi.  
Fix: Timer debounce (500ms) add kiya taaki last input ke baad hi API call ho.

2. Duplicate Tracks from API Search  
Issue: Search API se wahi tracks dobara aa rahe the jo pehle se list me the.  
Fix: Track IDs ka Set banake duplicate tracks ko filter kiya.

3. Pagination Trigger During Search
Issue: Search mode me bhi scroll pagination call ho rahi thi.  
Fix: Condition add ki if (state.searchQuery.isNotEmpty) return;`

4. UI Rebuild Performance Issue
Issue: Large track list hone par unnecessary UI rebuild ho rahi thi.  
Fix: Equatable use karke state comparison optimize kiya.




A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
