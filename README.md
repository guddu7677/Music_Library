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


5. app ka flow
App open hote hi main.dart mein LibraryBloc provide hota hai. Yeh BLoC poori app ke liye ek hi baar banta hai aur root pe hota hai kyunki library screen ko poori app mein chahiye.
LibraryScreen khulte hi LibraryStarted event fire hoti hai. BLoC yeh event pakadta hai, ApiService ke through server se pehle 50 tracks fetch karta hai, unhe alphabetically sort karke displayItems list banta hai jisme StickyHeaderItem (A, B, C headers) aur TrackListItem (actual tracks) mix hote hain. UI yeh list render karta hai.
#search
Jab user search box mein type karta hai, har keystroke pe LibrarySearchChanged(query) event jaati hai BLoC ko. BLoC us query se server pe nayi call karta hai. Purani list clear hoti hai, nayi aati hai.
Cross button press karo toh LibrarySearchCleared jaata hai — query empty ho jaati hai aur default 'a' se dobara tracks aate hain.
A few resources to get you started if this is your first Flutter project

#scrolling
ScrollController ka listener lagaya hai _LibraryScreenState mein. Jab user bottom se 400px door hota hai tab LibraryLoadMoreRequested fire hota hai.
BLoC check karta hai agar isLoadingMore true hai ya hasMore false hai toh event ignore karo. Warna index + limit pe nayi call jaati hai aur nayi tracks purani list mein append ho jaati hain.
hasMore ka logic simple hai — agar server ne 50 maange aur 50 diye toh probably aur hain.

#group
User Title A–Z ya Artist A–Z select karta hai. LibraryGroupByChanged event jaati hai. BLoC same allTracks list ko dobara sort aur group karta hai — nayi API call nahi jaati. Sirf displayItems rebuild hota hai

#issues

Issue 1: Duplicate scroll events — same tracks dobara aa rahe the
Kya hua: Jab user scroll karta tha, _onScroll listener milliseconds mein 4-5 baar fire ho jaata tha kyunki pixels >= maxScrollExtent - 400 condition kaafi der tak true rehti thi. Iska matlab ek hi baar scroll karne pe 4-5 API calls chali jaati thin aur same tracks list mein double ho jaate the.
Fix: BLoC mein isLoadingMore flag add kiya. Jab pehli call jaati hai toh flag true ho jaata hai. Jab tak response nahi aata tab tak nayi call nahi jaa

2.
Problem yeh thi ki jab user retry karta tha aur detail successfully load hoti thi, toh copyWith mein detailError: null pass hota tha. Lekin null ?? this.detailError matlab purana error string hi reh jaata tha state mein. Successful retry ke baad bhi error message dikhta tha.

Fix: Sentinel pattern use kiya — ek private object banaya jo "not passed" represent karta hai.




##  What Breaks at 100k Tracks
 ha kaafi kuch.
Client-side filtering slow ho jaayegi. Abhi search allTracks pe locally filter hoti hai. 100k objects RAM mein rakho aur har keystroke pe filter karo — low-end phones pe 200-300ms lag sakta hai. UI janky lagegi.
Memory pressure. 100k Track objects in-memory roughly 30-50MB+ RAM. Flutter handle kar leta hai but background mein app kill ho sakti hai low RAM phones pe.
displayItems rebuild costly hogi. Grouping aur sorting 100k items pe main thread block kar sakti hai.
hasMore edge case. Agar last page exactly 50 tracks pe khatam ho toh ek extra empty call jaayegi. Crash nahi hoga but useless network request

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
