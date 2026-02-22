# Dokumentasi Master Data: Jenis Barang

## Deskripsi

**Jenis Barang** adalah master data yang mendefinisikan jenis/material dari barang (contoh: Stainless Steel, Mild Steel, Aluminium, dll). Jenis barang digunakan sebagai salah satu atribut utama pengelompokan barang pada `ItemBarangGroup`.

---

## Database

**Tabel:** `ref_jenis_barang`  
**Model:** `App\Models\MasterData\JenisBarang`  
**Soft Delete:** ✅

| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | integer (PK) | Auto-increment |
| `kode` | string (unique) | Kode jenis barang (contoh: `SS`, `MS`, `AL`) |
| `nama_jenis` | string | Nama jenis barang (contoh: `Stainless Steel`) |
| `created_at` | timestamp | Waktu pembuatan |
| `updated_at` | timestamp | Waktu update terakhir |
| `deleted_at` | timestamp | Soft delete marker |

---

## API Endpoints

Base URL: `/api/jenis-barang`  
Middleware: `checkrole`

### 1. List Jenis Barang

```
GET /api/jenis-barang
```

**Query Parameters:**

| Parameter | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `per_page` | integer | ❌ | Jumlah data per halaman |
| `search` | string | ❌ | Pencarian di kolom `kode` dan `nama_jenis` |

**Response:**

```json
{
  "success": true,
  "data": [
    { "id": 1, "kode": "SS", "nama_jenis": "Stainless Steel" },
    { "id": 2, "kode": "MS", "nama_jenis": "Mild Steel" }
  ],
  "meta": { "current_page": 1, "last_page": 1, "per_page": 10, "total": 2 }
}
```

---

### 2. Detail Jenis Barang

```
GET /api/jenis-barang/{id}
```

**Response:** Single object jenis barang.

---

### 3. Tambah Jenis Barang

```
POST /api/jenis-barang
```

**Request Body:**

```json
{
  "kode": "SS",
  "nama_jenis": "Stainless Steel"
}
```

| Field | Tipe | Wajib | Validasi |
|---|---|---|---|
| `kode` | string | ✅ | Unique di `ref_jenis_barang` |
| `nama_jenis` | string | ✅ | - |

**Response Sukses:**

```json
{
  "success": true,
  "message": "Data berhasil ditambahkan",
  "data": { "id": 1, "kode": "SS", "nama_jenis": "Stainless Steel" }
}
```

---

### 4. Update Jenis Barang

```
PUT /api/jenis-barang/{id}
PATCH /api/jenis-barang/{id}
```

**Request Body:** Sama dengan store. Validasi `kode` unique kecuali untuk record sendiri.

---

### 5. Soft Delete

```
DELETE /api/jenis-barang/{id}/soft
```

Menandai data sebagai dihapus (soft delete).

---

### 6. Restore

```
PATCH /api/jenis-barang/{id}/restore
```

Mengembalikan data yang sudah di-soft delete.

---

### 7. Force Delete

```
DELETE /api/jenis-barang/{id}/force
```

Menghapus data secara permanen. Gagal jika data masih digunakan oleh data lain (FK constraint → error `409`).

---

### 8. List With Trashed

```
GET /api/jenis-barang/with-trashed/all
```

Menampilkan semua data termasuk yang di-soft delete.

---

### 9. List Trashed Only

```
GET /api/jenis-barang/with-trashed/trashed
```

Menampilkan hanya data yang di-soft delete.

---

## File Terkait

| File | Keterangan |
|---|---|
| `app/Http/Controllers/MasterData/JenisBarangController.php` | Controller |
| `app/Models/MasterData/JenisBarang.php` | Model |
| `routes/api.php` | Route definitions (line 152-166) |
