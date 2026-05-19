# EQX Doubles — Swift / SwiftUI iOS App 📱

A native iPhone app version of the EQX Doubles Finder, written in Swift and SwiftUI.
Connects to the same Supabase backend as the original web app — same database, same `find_doubles()` function.

---

## 🧠 What is Swift?

Swift is a **compiled language** created by Apple in 2014. It's the primary language for building apps on iPhone, iPad, Mac, Apple Watch, and Apple TV.

Unlike Python (which is *interpreted* — the computer reads and runs it line by line at runtime), Swift is **compiled** — a program called the *compiler* reads ALL your code before it runs, checks it for errors, and translates it into **machine code**: binary instructions the CPU can execute directly.

### What does "compiled" actually mean in practice?

1. You write `.swift` files (human-readable text, just like `.py` files)
2. You press **▶ Run** in Xcode
3. The **Swift compiler** (`swiftc`) reads every file, checks types, finds bugs, and translates your code into a binary
4. The binary (a `.app` bundle) runs on your iPhone or in the Simulator
5. The binary is *fast* — the CPU runs it directly, no interpreter in the middle

### Why does this matter?

| | Python | Swift |
|---|---|---|
| **How it runs** | Interpreter reads your `.py` at runtime | Compiler translates to binary *before* running |
| **Error discovery** | Errors show up when that line runs | Errors caught at compile time (before you even run it) |
| **Speed** | Slower (interpreter overhead) | Very fast (native machine code) |
| **Type system** | Dynamic (types checked at runtime) | Static (types checked at compile time) |
| **File extension** | `.py` | `.swift` |
| **Entry point** | `if __name__ == '__main__':` | `@main struct App: App { ... }` |

---

## 🔨 What is Xcode?

Xcode is Apple's **Integrated Development Environment (IDE)** — it's like VS Code but specifically built for Apple platforms. It includes:

- The **Swift compiler** (turns your `.swift` files into a `.app` binary)
- A **code editor** with autocomplete and syntax highlighting
- An **iOS Simulator** (runs iPhone apps on your Mac)
- A **debugger** (pause execution and inspect variables)
- An **Interface Builder** (visual UI designer, though we use SwiftUI code instead)
- The **App Store uploader** (to distribute your app)

You **cannot** build an iOS app without Xcode (or at least the command-line tools). This is unlike Python where you can run code with just `python app.py`.

---

## 🏗 What is SwiftUI?

SwiftUI is Apple's modern framework for building user interfaces in Swift (introduced 2019). Instead of writing HTML/CSS, you write Swift code that *declares* what the UI should look like.

```swift
// HTML equivalent:  <div class="card"><h2>Barre</h2><p>6:30 AM – 7:30 AM</p></div>

VStack(alignment: .leading) {
    Text("Barre")
        .font(.headline)
    Text("6:30 AM – 7:30 AM")
        .foregroundColor(.green)
}
.padding()
.background(Color(.systemGray6))
.cornerRadius(8)
```

SwiftUI is **declarative** — you describe *what* the UI is, and SwiftUI figures out *how* to draw it and update it when data changes.

---

## 📂 Project Structure

```
eqx-doubles-ios/
├── Package.swift                    — Swift Package Manager config (open this in Xcode)
├── README.md                        — You're reading it
└── EQXDoubles/
    ├── EQXDoublesApp.swift          — @main entry point (like __main__ in Python)
    ├── ContentView.swift            — Root view: TabView with Search + Results tabs
    ├── SearchViewModel.swift        — Business logic: holds state, triggers search
    ├── Models/
    │   ├── Club.swift               — Club struct + static data (all 36 NYC clubs)
    │   ├── DoubleResult.swift       — The result type returned by find_doubles()
    │   └── SearchParams.swift      — All the search form inputs as a struct
    ├── Services/
    │   └── SupabaseService.swift    — Makes HTTP calls to Supabase REST API
    └── Views/
        ├── SearchView.swift         — The search form (locations, categories, date, etc.)
        ├── ResultsView.swift        — The list of results
        └── ResultCard.swift         — One pair card (first class + second class)
```

### Key Swift concepts explained inline in the code:
- `struct` vs `class` — value types vs reference types
- `@State`, `@StateObject`, `@ObservedObject`, `@Published` — how SwiftUI tracks changes
- `View`, `body`, `some View` — the declarative UI model
- `async/await` — modern concurrency (like `async/await` in JavaScript)
- `Codable` — automatic JSON encoding/decoding
- `Binding` — two-way connections between data and UI

---

## 🚀 How to Open & Run in Xcode

### Step 1: Install Xcode
Download Xcode from the **Mac App Store** (it's free, ~10GB).

### Step 2: Open the project
1. Open Xcode
2. **File → Open** (or drag the `eqx-doubles-ios` folder onto Xcode)
3. Xcode will detect the `Package.swift` and load the project

### Step 3: For a proper iOS App target (recommended)
The `Package.swift` is good for previewing code. For a full iOS app with a simulator:
1. **File → New → Project**
2. Choose **iOS → App**
3. Product name: `EQXDoubles`, Interface: `SwiftUI`, Language: `Swift`
4. Delete the auto-generated `ContentView.swift`
5. Drag all `.swift` files from this repo into the new project

### Step 4: Run in Simulator
1. At the top of Xcode, click the device selector and choose an iPhone simulator
2. Press **▶** (or Cmd+R)
3. Xcode compiles your code (you'll see a progress bar)
4. The Simulator opens and your app launches 🎉

### What just happened?
```
Your .swift files
      ↓  (Swift compiler reads all files)
      ↓  (checks types, finds errors)
      ↓  (translates to machine code)
   .app bundle
      ↓  (Xcode installs on Simulator)
   Running on iPhone Simulator 📱
```

---

## 🔁 How This Compares to the Other Versions

| | Original (Web) | Python (Flask) | Swift (iOS) |
|---|---|---|---|
| **Language** | HTML + JavaScript | Python | Swift |
| **How it runs** | Browser reads HTML directly | Python interpreter runs `app.py` | Compiler produces binary → runs on iPhone |
| **Where Supabase is called** | In the browser (JS) | On the server (Python) | In the app (Swift) |
| **UI framework** | HTML/CSS | HTML/CSS + Jinja2 | SwiftUI |
| **Runs on** | Any web browser | Web browser (via Flask server) | iPhone / iPad / iOS Simulator |
| **Deploy to users** | GitHub Pages / Vercel | Heroku / Railway / Render | App Store (requires $99/yr developer account) |

---

## 🔑 Supabase Connection

The app connects to the same Supabase project as the original web app:
- **URL**: `https://hprkoonlydcjqxrgjwtr.supabase.co`
- **Anon Key**: stored in `SupabaseService.swift`

The app calls the same `find_doubles()` PostgreSQL function via Supabase's REST API.
No separate backend needed — the iOS app talks directly to Supabase over HTTPS.
