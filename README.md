# Flutter Generative UI & Firebase Template 🚀

Selamat datang di repository pembelajaran **Flutter Generative UI (GenUI) SDK & Firebase MCP**! Template ini dirancang untuk membantumu memahami bagaimana cara membuat chatbot AI yang tidak hanya menjawab dengan teks biasa, tetapi juga bisa memunculkan UI component secara dinamis langsung di dalam chat bubble.

Project ini bersifat **generik** dan tidak terikat pada satu use case tertentu (seperti e-commerce). Kamu bebas memodifikasi template ini menjadi aplikasi apa saja sesuai kreativitasmu (e.g. Smart Home Control, Travel Guide, Personal Finance Tracker, dll).

---

## 📋 Panduan Setelah Clone (Untuk Teman-Teman)

Jika teman-teman baru saja melakukan clone repository `flutter-genui-sdk-firebase-template`, berikut adalah langkah-langkah yang harus mereka lakukan untuk memulai:

### 1. Setup Environment Aplikasi Flutter
1. **Instal Dependensi**:
   Buka terminal di folder project, lalu jalankan:
   ```bash
   flutter pub get
   ```
2. **Duplikat file `.env`**:
   Salin file `.env.example` menjadi `.env`:
   ```bash
   cp .env.example .env
   ```
   Buka file `.env` baru tersebut, lalu isi dengan API Key Gemini milikmu (dapatkan di [Google AI Studio](https://aistudio.google.com/)) dan detail project Firebase milikmu (bisa didapatkan di Firebase Console bagian Project Settings):
   ```env
   GEMINI_API_KEY=AIzaSy...
   
   # Firebase Config (General)
   FIREBASE_PROJECT_ID=your_project_id
   FIREBASE_MESSAGING_SENDER_ID=your_sender_id
   FIREBASE_STORAGE_BUCKET=your_storage_bucket
   
   # Firebase Web Config
   FIREBASE_API_KEY_WEB=your_web_api_key
   FIREBASE_APP_ID_WEB=your_web_app_id
   FIREBASE_AUTH_DOMAIN=your_auth_domain
   
   # Firebase Android Config
   FIREBASE_API_KEY_ANDROID=your_android_api_key
   FIREBASE_APP_ID_ANDROID=your_android_app_id
   
   # Firebase iOS Config
   FIREBASE_API_KEY_IOS=your_ios_api_key
   FIREBASE_APP_ID_IOS=your_ios_app_id
   FIREBASE_IOS_BUNDLE_ID=your_bundle_id
   ```

3. **Unduh File Konfigurasi Native Firebase**:
   Unduh berkas setelan native dari Firebase Console untuk project Anda, lalu salin/gantikan ke direktori berikut:
   * **Android**: Letakkan `google-services.json` di folder `android/app/google-services.json`
   * **iOS**: Letakkan `GoogleService-Info.plist` di folder `ios/Runner/GoogleService-Info.plist`
   * **macOS**: Letakkan `GoogleService-Info.plist` di folder `macos/Runner/GoogleService-Info.plist`
   
   *(Catatan: Langkah ini wajib karena Firebase SDK native di Android & iOS membutuhkan file fisik tersebut untuk inisialisasi awal).*

4. **Sambungkan & Deploy Database Firestore**:
   Aplikasi ini memerlukan Firebase Firestore. Pastikan Firebase CLI terinstall di laptop masing-masing (`npm install -g firebase-tools`).
   Lakukan login ke Firebase CLI:
   ```bash
   firebase login
   ```
   Hubungkan project lokal ini dengan project ID Firebase yang Anda miliki:
   ```bash
   firebase use --add
   ```
   *(Pilih project ID Firebase Anda saat diminta, lalu beri nama alias **`default`**).*

   Deploy aturan keamanan (rules) & indeks Firestore bawaan template ke project Firebase Anda:
   ```bash
   firebase deploy --only firestore
   ```
   *(Langkah ini sangat penting agar Firestore Anda memiliki hak akses baca-tulis serta indeks query yang dibutuhkan oleh template).*

5. **Jalankan Aplikasi & Seed Data**:
   Jalankan aplikasi (Gunakan **Cold Run/Rebuild penuh** saat pertama kali memasang file config native baru, jangan sekadar Hot Restart):
   ```bash
   flutter run
   ```
   Pada halaman awal aplikasi (Dashboard), jika database Firestore masih kosong, akan muncul tombol **"Seed Generic Mock Data"**. Klik tombol tersebut untuk otomatis mengunggah data dummy contoh ke Firestore database-mu.

---

## 🤖 Setup Firebase MCP Server di IDE (Cursor / VS Code / Antigravity)

**Model Context Protocol (MCP)** memungkinkan asisten AI di IDE teman-teman (seperti Cursor atau Google Antigravity) untuk terhubung secara langsung ke database Firebase Firestore milik mereka. Dengan begitu, AI asisten bisa tahu data apa saja yang ada di database, melihat riwayat chat, dan membantu mendebug data Firestore secara real-time.

Berikut cara mengaturnya:

### Langkah A: Buat Service Account Key dari Firebase Console
1. Buka [Firebase Console](https://console.firebase.google.com/).
2. Masuk ke project Firebase yang digunakan.
3. Klik ikon Gear ⚙️ (**Project Settings**) -> Pilih tab **Service Accounts**.
4. Klik tombol **Generate New Private Key**, lalu simpan file JSON tersebut ke laptopmu (misal disimpan di `/Users/username/firebase-key.json`).
5. **PENTING**: Jangan masukkan file JSON ini ke dalam folder project agar tidak tidak sengaja ter-commit ke GitHub!

### Langkah B: Daftarkan Firebase MCP Server di IDE

#### Pilihan 1: Di Cursor IDE
1. Buka **Cursor Settings** (ikon Gear di pojok kanan atas, atau tekan `Cmd + ,` / `Ctrl + ,`).
2. Masuk ke menu **Features** -> scroll ke bagian **MCP**.
3. Klik **+ Add New MCP Server**.
4. Isi form dengan detail berikut:
   * **Name**: `firebase-mcp`
   * **Type**: `command`
   * **Command**: 
     ```bash
     npx -y @sualeh/mcp-server-firebase
     ```
   * **Environment Variables**:
     Tambahkan key berikut agar server tahu lokasi file credentials Firebase-mu:
     * Key: `GOOGLE_APPLICATION_CREDENTIALS`
     * Value: `/absolute/path/ke/file/firebase-key.json` (Ganti dengan path file JSON yang didownload di Langkah A).
5. Klik **Save**. Pastikan statusnya menjadi hijau / *connected*.

#### Pilihan 2: Di Google Antigravity / Claude Desktop
Tambahkan konfigurasi berikut ke file setelan MCP (`claude_desktop_config.json`):
```json
{
  "mcpServers": {
    "firebase-mcp": {
      "command": "npx",
      "args": ["-y", "@sualeh/mcp-server-firebase"],
      "env": {
        "GOOGLE_APPLICATION_CREDENTIALS": "/absolute/path/ke/file/firebase-key.json"
      }
    }
  }
}
```

Setelah terhubung, kamu bisa langsung mengetes AI-mu di chat:
* *"Coba periksa di Firestore, ada berapa dokumen di koleksi 'items'?"*
* *"Tolong tambahkan item baru dengan judul 'Item Eksperimen' ke Firestore."*

---

## 💡 Konsep Utama Generative UI (GenUI)
Tradisional chatbot hanya menampilkan jawaban berupa teks (Markdown). Dengan **Generative UI**, model AI (dalam hal ini **Gemini 2.5 Flash**) dilatih menggunakan system instruction khusus untuk mengeluarkan struktur data JSON saat ingin menyajikan informasi visual. 

Aplikasi Flutter kita menggunakan paket `genui` untuk:
* Mendeteksi data JSON yang mengalir dari stream model.
* Mencocokkan nama komponen dengan **Catalog** yang sudah didaftarkan.
* Merender component tersebut secara dinamis (misal: widget `TextCard`, `ImageCard`, atau `ComparisonTable`) dengan data yang disuplai oleh AI.

---

## 🛠️ Langkah demi Langkah Implementasi Coding

Kamu perlu melengkapi kode di dua file utama:

### Langkah 1: Melengkapi Catalog Widget (`lib/models/custom_catalog.dart`)
Buka file `lib/models/custom_catalog.dart`. Daftarkan schema JSON dan builder widget untuk component yang ingin didukung, seperti:
1. **Column**: Untuk menampung beberapa widget sekaligus.
2. **TextCard**: Card sederhana untuk info teks.
3. **ImageCard**: Card dengan gambar, judul, dan caption.
4. **InteractiveButton**: Tombol yang memicu action/callback.
5. **ComparisonTable**: Tabel untuk membandingkan baris data.
6. **StatusIndicator**: Indikator status (misal: sukses, pending, error).

> Kode lengkap referensi implementasi catalog bisa dilihat di file `.cursorrules` atau tanyakan langsung ke asisten AI-mu!

### Langkah 2: Mengintegrasikan GenUI di Chat (`lib/screens/ai_chat_screen.dart`)
Buka file `lib/screens/ai_chat_screen.dart` dan lakukan:
1. Import library:
   ```dart
   import 'package:genui/genui.dart';
   import 'package:google_generative_ai/google_generative_ai.dart' as ai;
   ```
2. Inisialisasi **SurfaceController**, **A2uiTransportAdapter**, dan **Conversation**.
3. Setup **GenerativeModel** dengan API Key Gemini dan berikan system instruction agar model paham kapan harus menggunakan JSON protocol.
4. Buat fungsi filtering regex `_cleanResponse` agar string JSON mentah tidak bocor masuk ke gelembung chat teks (text bubble).
5. Pada ListView builder pesan, tambahkan kondisi untuk merender widget `Surface` jika pesan tersebut memiliki `surfaceId`.

Selamat belajar dan berkreasi dengan Generative UI! 🎨💻
