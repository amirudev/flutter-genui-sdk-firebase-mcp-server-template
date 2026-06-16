# Flutter Generative UI & Firebase Template 🚀

Selamat datang di repository pembelajaran **Flutter Generative UI (GenUI) SDK & Firebase MCP**! Template ini dirancang untuk membantumu memahami bagaimana cara membuat chatbot AI yang tidak hanya menjawab dengan teks biasa, tetapi juga bisa memunculkan UI component interaktif secara dinamis langsung di dalam chat bubble.

---

## 📋 Panduan Setelah Clone (Untuk Teman-Temanmu)

Jika teman-temanmu baru saja melakukan clone repository `flutter-genui-sdk-firebase-template`, berikut adalah langkah-langkah yang harus mereka lakukan untuk memulai:

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
   Buka file `.env` baru tersebut, lalu isi dengan API Key Gemini milikmu (dapatkan di [Google AI Studio](https://aistudio.google.com/)):
   ```env
   GEMINI_API_KEY=AIzaSy...
   ```
3. **Sambungkan dengan Firebase (Inisialisasi)**:
   Aplikasi ini memerlukan Firebase Firestore. Pastikan Firebase CLI terinstall di laptop masing-masing (`npm install -g firebase-tools`).
   Lakukan login:
   ```bash
   firebase login
   ```
   Hubungkan project Flutter ini dengan project Firebase-mu:
   ```bash
   flutterfire configure
   ```
   *(Pilih project Firebase yang sudah ada, atau buat project baru via CLI ini. Ini akan memperbarui file `lib/firebase_options.dart` secara otomatis).*

4. **Jalankan Aplikasi & Seed Data**:
   Jalankan aplikasi di Emulator/Simulator/Web:
   ```bash
   flutter run
   ```
   Pada halaman awal aplikasi (Shop), jika database Firestore masih kosong, akan muncul tombol **"Seed Mock Data to Firestore"**. Klik tombol tersebut untuk otomatis mengunggah data produk contoh ke Firestore database-mu.

---

## 🤖 Setup Firebase MCP Server di IDE (Cursor / VS Code / Antigravity)

**Model Context Protocol (MCP)** memungkinkan asisten AI di IDE teman-temanmu (seperti Cursor atau Google Antigravity) untuk terhubung secara langsung ke database Firebase Firestore milik mereka. Dengan begitu, AI asisten bisa tahu barang apa saja yang ada di inventory, melihat riwayat chat, dan membantu mendebug data Firestore secara real-time.

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
* *"Coba periksa di Firestore, apa produk dengan ID prod_1 harganya sudah benar?"*
* *"Tolong buatkan diskon 15% untuk produk 'Modern Minimalist Watch' di database Firestore."*

---

## 💡 Konsep Utama Generative UI (GenUI)
Tradisional chatbot hanya menampilkan jawaban berupa teks (Markdown). Dengan **Generative UI**, model AI (dalam hal ini **Gemini 2.5 Flash**) dilatih menggunakan system instruction khusus untuk mengeluarkan struktur data JSON saat ingin menyajikan informasi visual. 

Aplikasi Flutter kita menggunakan paket `genui` untuk:
* Mendeteksi data JSON yang mengalir dari stream model.
* Mencocokkan nama komponen dengan **Catalog** yang sudah didaftarkan.
* Merender component tersebut secara dinamis (misal: widget `ProductCard`, `OrderStatus`, atau `ComparisonTable`) dengan data yang disuplai oleh AI.

---

## 🛠️ Langkah demi Langkah Implementasi Coding

Kamu perlu melengkapi kode di dua file utama:

### Langkah 1: Melengkapi Catalog Widget (`lib/models/help_desk_catalog.dart`)
Buka file `lib/models/help_desk_catalog.dart`. Daftarkan schema JSON dan builder widget untuk component yang ingin didukung, seperti:
1. **Column**: Untuk menampung beberapa widget sekaligus.
2. **ProductCard**: Untuk menampilkan info produk (Gambar, Nama, Harga).
3. **FAQCard**: Expansion tile untuk tanya jawab.
4. **OrderStatus**: Menampilkan status pengiriman barang.
5. **PromoCard**: Menampilkan voucher diskon menarik dengan gradient warna.
6. **ComparisonTable**: Tabel untuk membandingkan spesifikasi beberapa produk.
7. **SupportContact**: Tombol sekali klik untuk hubungi support.

> Kode lengkap referensi implementasi catalog bisa dilihat di file `.cursorrules` atau tanyakan langsung ke asisten AI-mu!

### Langkah 2: Mengintegrasikan GenUI di Chat (`lib/screens/help_desk_screen.dart`)
Buka file `lib/screens/help_desk_screen.dart` dan lakukan:
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
