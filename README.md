# Novel_Technology_TMDB

It connects to **The Movie Database (TMDb) API** to display a list of movies, allows searching with debounce to reduce unnecessary API calls, and caches popular movies locally using **Core Data** for offline access.

---

## 📌 Tech Stack
- **Swift** – iOS app development
- **UIKit** – UI framework
- **Core Data** – Local offline caching
- **TMDb API** – Movie data provider
- **SDWebImage** – Image downloading & caching
- **NSFetchedResultsController** – Core Data integration with UI updates

---

## ✨ Features
- Movie listing (movies)
- Search movies by title (with debounce to limit API requests)
- Offline caching of popular movies using Core Data
- Movie details screen showing:
  - Poster image
  - Title
  - Release year
  - Overview
  - Rating
- Loading view for initial API fetch
- Footer spinner when loading more data (pagination)

---

## 🛠 Installation & Setup

1. **Clone this repository**
   git clone <repository_url>
   cd MovieExplorer
   sudo gem install cocoapods
   pod install
   open MovieExplorer.xcworkspace
