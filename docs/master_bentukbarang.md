# Dokumentasi Master Data: Bentuk Barang

## Deskripsi

**Bentuk Barang** adalah master data yang mendefinisikan bentuk/shape dari barang (contoh: Plat, Pipa, Besi Siku, dll). Setiap bentuk barang memiliki relasi ke **Tipe Barang** yang menentukan dimensi apa saja yang berlaku untuk bentuk tersebut.

---

## Database

**Tabel:** `ref_bentuk_barang`  
**Model:** `App\Models\MasterData\BentukBarang`  
**Soft Delete:** ✅

| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | integer (PK) | Auto-increment |
| `kode` | string (unique) | Kode bentuk barang (contoh: `PL`, `PP`) |
| `nama_bentuk` | string | Nama bentuk barang (contoh: `Plat`, `Pipa`) |
| `dimensi` | string | Tipe dimensi (`1D` atau `2D`) |
| `tipe_barang_id` | integer (FK) | Relasi ke `ref_tipe_barang` |
| `created_at` | timestamp | Waktu pembuatan |
| `updated_at` | timestamp | Waktu update terakhir |
| `deleted_at` | timestamp | Soft delete marker |

### Relasi

| Relasi | Tipe | Model Tujuan | Keterangan |
|---|---|---|---|
| `tipeBarang` | BelongsTo | `TipeBarang` | Tipe barang yang menentukan dimensi |

---

## API Endpoints

Base URL: `/api/bentuk-barang`  
Middleware: `checkrole`

### 1. List Bentuk Barang

```
GET /api/bentuk-barang
```

**Query Parameters:**

| Parameter | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `per_page` | integer | ❌ | Jumlah data per halaman (default dari config) |
| `search` | string | ❌ | Pencarian di kolom `kode` dan `nama_bentuk` |

**Response:** Paginated list dengan relasi `tipeBarang`

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "kode": "PL",
      "nama_bentuk": "Plat",
      "dimensi": "2D",
      "tipe_barang_id": 1,
      "tipe_barang": {
        "id": 1,
        "nama": "Plat",
        "panjang": true,
        "lebar": true,
        "tebal": true,
        "diameter_luar": false,
        "diameter_dalam": false,
        "diameter": false,
        "sisi1": false,
        "sisi2": false
      }
    }
  ],
  "meta": { "current_page": 1, "last_page": 1, "per_page": 10, "total": 1 }
}
```

---

### 2. Detail Bentuk Barang

```
GET /api/bentuk-barang/{id}
```

**Response:** Single object dengan relasi `tipeBarang`

---

### 3. Tambah Bentuk Barang

```
POST /api/bentuk-barang
```

**Request Body:**

```json
{
  "kode": "PL",
  "nama_bentuk": "Plat",
  "tipe_barang_id": 1
}
```

| Field | Tipe | Wajib | Validasi |
|---|---|---|---|
| `kode` | string | ✅ | Unique di `ref_bentuk_barang` |
| `nama_bentuk` | string | ✅ | - |
| `tipe_barang_id` | integer | ✅ | Harus ada di `ref_tipe_barang` |

**Response Sukses:**

```json
{
  "success": true,
  "message": "Data berhasil ditambahkan",
  "data": { "id": 1, "kode": "PL", "nama_bentuk": "Plat", "tipe_barang_id": 1 }
}
```

---

### 4. Update Bentuk Barang

```
PUT /api/bentuk-barang/{id}
PATCH /api/bentuk-barang/{id}
```

**Request Body:** Sama dengan store. Validasi `kode` unique kecuali untuk record sendiri.

---

### 5. Soft Delete

```
DELETE /api/bentuk-barang/{id}/soft
```

Menandai data sebagai dihapus (soft delete). Data masih tersimpan di database.

---

### 6. Restore

```
PATCH /api/bentuk-barang/{id}/restore
```

Mengembalikan data yang sudah di-soft delete.

---

### 7. Force Delete

```
DELETE /api/bentuk-barang/{id}/force
```

Menghapus data secara permanen. Gagal jika data masih digunakan oleh data lain (FK constraint → error `409`).

---

### 8. List With Trashed

```
GET /api/bentuk-barang/with-trashed/all
```

Menampilkan semua data termasuk yang di-soft delete.

---

### 9. List Trashed Only

```
GET /api/bentuk-barang/with-trashed/trashed
```

Menampilkan hanya data yang di-soft delete.

---

## File Terkait

| File | Keterangan |
|---|---|
| `app/Http/Controllers/MasterData/BentukBarangController.php` | Controller |
| `app/Models/MasterData/BentukBarang.php` | Model |
| `routes/api.php` | Route definitions (line 169-183) |
