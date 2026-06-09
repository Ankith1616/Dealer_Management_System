# ColorCraft Paints 🎨
### *Premium Paint Shop & Dealer Management System*

ColorCraft Paints is a state-of-the-art Flutter web and mobile application designed for paint dealers and customers to explore, compare, and manage paint products. It features a curated selection of leading paint brands (Asian Paints, Berger Paints, Nerolac Paints, Birla Opus, Dr. Fixit, Surya) and categories (Interior, Exterior, Primer, Wall Care, Waterproofing, and more).

---

## ✨ Features

- **Interactive Category Dashboard**: Clean, responsive layout categorized into Interior Walls, Exterior Walls, Primers, Enamels, Waterproofing, Distempers, Textures, Wood Finishes, Wall Care, and General items.
- **Advanced Product Catalog & Search**: Instant full-text search and multi-parameter filters (by Brand, Coat Type, Usage/Environment, Price Range, and Sorting).
- **Comprehensive Product Details**: Technical specifications (coverage, drying time, warranty, sizes), product ratings, and customer reviews with dealer replies.
- **Visual Product Comparison**: Side-by-side comparison tool with detailed feature comparisons and interactive visual analysis charts.
- **Dealer Management Panel**: Restricted dealer screen to dynamically add, edit, and delete products from the catalog.
- **Modern Premium Design**: Dark and light mode adaptability, HSL tailored gradients, glassmorphism card components, and fluid animations.

---

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev) (Web & Mobile support)
- **State Management**: [Riverpod](https://riverpod.dev) (for clean, reactive state synchronization)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
- **Data Visualizations**: [FL Chart](https://pub.dev/packages/fl_chart)
- **Styling**: Vanilla Flutter Custom Decoration & Glassmorphism widgets

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.11.0 or higher recommended)
- Dart SDK

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Ankith1616/Dealer_Management_System.git
   cd Dealer_Management_System
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application locally**:
   ```bash
   flutter run -d chrome
   ```

4. **Run tests**:
   ```bash
   flutter test
   ```

---

## 📦 Deployment

This project is configured with **GitHub Actions** for continuous integration and deployment to **Firebase Hosting**.

- Push to the `main` branch automatically triggers the `.github/workflows/firebase-hosting-merge.yml` pipeline.
- It installs dependencies, builds the release web bundle (`flutter build web`), and deploys directly to Firebase Hosting.
