# 📚 VocabBoost — Adaptive English Vocabulary Trainer

<p align="center">
  <img src="screenshots/quiz_screen.png" alt="Quiz Screen" width="250"/>
  <img src="screenshots/import_screen.png" alt="Import Screen" width="250"/>
  <img src="screenshots/results_screen.png" alt="Results Screen" width="250"/>
</p>

An Android app that helps you expand your English vocabulary through adaptive quizzes, text-to-speech pronunciation, and smart spaced repetition. Import your own word lists and let the algorithm focus on the words you struggle with the most.

---

## ✨ Features

- **📂 Import Word Lists** — Load your own vocabulary from `.csv` or `.txt` files (`word;translation` format).
- **🧠 Adaptive Quiz Mode** — Multiple-choice questions (1 correct + 3 distractors). Words you get wrong appear more frequently thanks to a weighted random algorithm.
- **🔊 Text-to-Speech** — Tap a button to hear the correct English pronunciation of any word (powered by Android's built-in TTS engine).
- **📊 Progress Tracking** — Each word stores its own statistics: correct/incorrect count and a dynamic weight score.
- **💾 Offline & Private** — All data is stored locally on your device using Room database. No internet required. No data leaves your phone.

---

## 🧮 How the Adaptive Algorithm Works

Every word has a `weight` value (starts at `1.0`):

| Event | Weight Change | Effect |
|---|---|---|
| ❌ Wrong answer | `weight × 2.5` | Word appears **more often** |
| ✅ Correct answer | `weight ÷ 2.0` (min `1.0`) | Word appears **less often** |

When generating a quiz question, the app uses **weighted random selection** — the higher the weight, the greater the probability that the word will be chosen. This ensures you practice your weakest words more intensively.

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| Language | Kotlin |
| UI | Jetpack Compose |
| Database | Room (SQLite) |
| Architecture | MVVM |
| Audio | Android TextToSpeech API |
| File Import | Activity Result API (`GetContent`) |
| Min SDK | 26 (Android 8.0) |

---

## 📦 Installation

### From Source

1. Clone the repository:
   ```bash
   git clone https://github.com/sciensfeja/VocabBoost.git
