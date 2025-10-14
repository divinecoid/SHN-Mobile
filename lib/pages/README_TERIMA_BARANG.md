# Struktur Halaman Terima Barang

Halaman terima barang telah dipecah menjadi beberapa halaman terpisah untuk meningkatkan maintainability dan modularity.

## Struktur Halaman

### 1. TerimaBarangMainPage
- **File**: `terima_barang_main_page.dart`
- **Fungsi**: Halaman utama dengan bottom navigation untuk navigasi antara daftar dan input
- **Navigasi**: Menggunakan IndexedStack untuk menjaga state

### 2. PenerimaanBarangListPage
- **File**: `penerimaan_barang_list_page.dart`
- **Fungsi**: Menampilkan daftar penerimaan barang dengan fitur:
  - Pagination
  - Search
  - Refresh
  - Navigasi ke detail
- **Controller**: `PenerimaanBarangListController`

### 3. InputPenerimaanBarangPage
- **File**: `input_penerimaan_barang_page.dart`
- **Fungsi**: Form input penerimaan barang dengan fitur:
  - Pilih origin (Purchase Order / Stock Mutation)
  - Pilih gudang
  - Input catatan
  - Upload foto
  - Tambah detail barang
- **Navigasi**: Ke halaman scan barang untuk menambah detail

### 4. ScanBarangPage
- **File**: `scan_barang_page.dart`
- **Fungsi**: Scan QR code barang menggunakan kamera
- **Fitur**:
  - Camera scanner dengan overlay
  - Input manual sebagai fallback
  - Navigasi ke scan rak setelah berhasil scan

### 5. ScanRakPage
- **File**: `scan_rak_page.dart`
- **Fungsi**: Scan QR code rak menggunakan kamera
- **Fitur**:
  - Camera scanner dengan overlay
  - Input manual sebagai fallback
  - Navigasi ke input detail setelah berhasil scan

### 6. InputDetailPenerimaanBarangPage
- **File**: `input_detail_penerimaan_barang_page.dart`
- **Fungsi**: Input detail penerimaan barang (quantity)
- **Fitur**:
  - Validasi form
  - Konfirmasi detail
  - Navigasi kembali ke halaman input

### 7. PenerimaanBarangDetailPage
- **File**: `penerimaan_barang_detail_page.dart`
- **Fungsi**: Menampilkan detail lengkap penerimaan barang
- **Fitur**:
  - Informasi penerimaan
  - Informasi origin (PO/Stock Mutation)
  - Informasi gudang
  - Catatan
  - Foto (jika ada)
  - Daftar detail barang

## Model dan Controller

### Model
- **PenerimaanBarangModel**: `penerimaan_barang_model.dart`
  - Model untuk data penerimaan barang sesuai dengan API
  - Mendukung Purchase Order dan Stock Mutation
  - Include detail barang dan gudang

### Controller
- **PenerimaanBarangListController**: `penerimaan_barang_list_controller.dart`
  - Controller untuk mengelola daftar penerimaan barang
  - Fitur pagination, search, dan CRUD operations
  - Integrasi dengan API

- **TerimaBarangController**: `terima_barang_controller.dart` (Updated)
  - Controller yang sudah ada, diupdate untuk mendukung API baru
  - Tetap kompatibel dengan halaman lama

## API Integration

### Endpoints
- `GET /api/penerimaan-barang` - List penerimaan barang
- `POST /api/penerimaan-barang` - Create penerimaan barang
- `GET /api/penerimaan-barang/{id}` - Detail penerimaan barang

### Request/Response Format
Mengikuti format yang telah ditentukan dalam requirement:
- Support untuk Purchase Order dan Stock Mutation
- Include detail barang dengan quantity
- Support upload foto
- Pagination dan search

## Navigasi Flow

```
TerimaBarangMainPage
├── PenerimaanBarangListPage
│   └── PenerimaanBarangDetailPage
└── InputPenerimaanBarangPage
    └── ScanBarangPage
        └── ScanRakPage
            └── InputDetailPenerimaanBarangPage
```

## Penggunaan

Untuk menggunakan halaman baru, ganti navigasi ke `TerimaBarangMainPage`:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const TerimaBarangMainPage(),
  ),
);
```

## Environment Variables

Pastikan environment variables berikut tersedia:
- `BASE_URL`: Base URL untuk API
- `API_PENERIMAAN_BARANG`: Path API untuk penerimaan barang (default: `/api/penerimaan-barang`)
- `API_GUDANG`: Path API untuk gudang (default: `/api/gudang`)

## Dependencies

Pastikan dependencies berikut tersedia di `pubspec.yaml`:
- `google_mlkit_barcode_scanning`: Untuk QR code scanning
- `camera`: Untuk kamera preview
- `http`: Untuk API calls
- `shared_preferences`: Untuk token storage
- `image_picker`: Untuk foto upload
- `flutter_dotenv`: Untuk environment variables
