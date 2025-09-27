# Simulasi Sistem Antrian Dua Server Restoran Drive-in

![Dashboard Preview](https://raw.githubusercontent.com/Ryslam/ui.ac.id-two-carhops-simulation/main/assets/dashboard-screenshot.png)

**Dashboardnya bisa diakses di link berikut:**
➡️ [https://ardian.shinyapps.io/ui-ac-id-two-carhops-simulation/](https://ardian.shinyapps.io/ui-ac-id-two-carhops-simulation/)

## 📜 Deskripsi
Aplikasi **Shiny** ini dirancang untuk melakukan simulasi dan analisis sistem antrian dengan dua server, yang diberi nama **Ali** dan **Badu**. Kedua server memiliki kecepatan layanan yang berbeda.
Tujuan utama dari aplikasi ini adalah untuk membandingkan **tiga strategi** atau skenario berbeda dalam menugaskan pelanggan ke server ketika keduanya sedang tidak sibuk (*idle*).

Aplikasi ini membantu menjawab pertanyaan-pertanyaan kunci dalam manajemen operasi, seperti:

- Strategi mana yang paling efektif untuk meminimalkan waktu tunggu pelanggan?
- Bagaimana setiap strategi memengaruhi beban kerja dan waktu menganggur (*idle time*) masing-masing server?
- Bagaimana hasil simulasi berubah dengan jumlah pelanggan dan variasi acak yang berbeda?

## ✨ Fitur Utama
- **Perbandingan Tiga Skenario**:
  1. *Pilihan Acak*: Server dipilih secara acak ketika keduanya idle.
  2. *Prioritas Ali*: Server **Ali** (lebih cepat) selalu diprioritaskan ketika keduanya idle.
  3. *Prioritas Badu*: Server **Badu** (lebih lambat) selalu diprioritaskan ketika keduanya idle.

- **Input Interaktif**:
  Sesuaikan *Jumlah Pelanggan* dan *Randomness Seed* menggunakan slider untuk melihat dampaknya pada hasil secara real-time.

- **Dashboard KPI Komprehensif**:
  Bandingkan kinerja setiap skenario melalui metrik kunci dalam *Value Box*:
  - Rata-rata Durasi Menunggu Dilayani
  - Durasi Menunggu Dilayani Terlama
  - Total Pelanggan yang Dilayani oleh Ali & Badu
  - Total Durasi Idle untuk Ali & Badu

- **Tabel Hasil Rinci**:
  Data hasil simulasi langkah demi langkah untuk setiap pelanggan dalam tabel interaktif.

- **Parameter Transparan**:
  Probabilitas untuk waktu antar-kedatangan dan waktu layanan ditampilkan di sidebar untuk referensi.

## ⚙️ Model Simulasi
Simulasi ini berbasis **discrete-event** dengan parameter probabilitas berikut:

- **Waktu Antar Kedatangan Pelanggan**:
  - 1 menit: 25%
  - 2 menit: 40%
  - 3 menit: 20%
  - 4 menit: 15%

- **Waktu Layanan Ali (Server Cepat)**:
  - 2 menit: 30%
  - 3 menit: 28%
  - 4 menit: 25%
  - 5 menit: 17%

- **Waktu Layanan Badu (Server Lambat)**:
  - 3 menit: 35%
  - 4 menit: 25%
  - 5 menit: 20%
  - 6 menit: 20%

## 🚀 (Opsional) Jalankan Aplikasi Secara Lokal

### Prasyarat
- Sudah menginstal **R**
- Sudah menginstal **RStudio Desktop**

### 1. Clone Repository
```bash
git clone [https://github.com/Ryslam/ui.ac.id-two-carhops-simulation.git](https://github.com/Ryslam/ui.ac.id-two-carhops-simulation.git)
cd ui.ac.id-two-carhops-simulation
```

### 2. Instalasi Packages
Buka **RStudio**, lalu jalankan perintah berikut di **console** untuk menginstal package yang dibutuhkan:
```r
install.packages(c("shiny", "shinydashboard", "DT"))
```

### 3. Clone Repository
```bash
shiny::runApp('app.R')
```
atau ctrl/command + shift + enter/return.

---
Jazakallah khairan, Ardian.
