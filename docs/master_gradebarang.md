# Dokumentasi Master Data: Grade Barang

## Deskripsi

**Grade Barang** adalah master data yang mendefinisikan tingkatan kualitas/grade dari barang (contoh: Grade A, Grade B, dll). Grade digunakan sebagai salah satu atribut pengelompokan barang pada `ItemBarangGroup`.

---

## Database

**Tabel:** `ref_grade_barang`  
**Model:** `App\Models\MasterData\GradeBarang`  
**Soft Delete:** ✅

| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | integer (PK) | Auto-increment |
| `kode` | string (unique) | Kode grade (contoh: `A`, `B`, `C`) |
| `nama` | string | Nama grade (contoh: `Grade A`, `Grade B`) |
| `created_at` | timestamp | Waktu pembuatan |
| `updated_at` | timestamp | Waktu update terakhir |
| `deleted_at` | timestamp | Soft delete marker |

---

## API Endpoints

Base URL: `/api/grade-barang`  
Middleware: `checkrole`

### 1. List Grade Barang

```
GET /api/grade-barang
```

**Query Parameters:**

| Parameter | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `per_page` | integer | ❌ | Jumlah data per halaman |
| `search` | string | ❌ | Pencarian di kolom `kode` dan `nama` |

**Response:**

```json
{
  "success": true,
  "data": [
    { "id": 1, "kode": "A", "nama": "Grade A" },
    { "id": 2, "kode": "B", "nama": "Grade B" }
  ],
  "meta": { "current_page": 1, "last_page": 1, "per_page": 10, "total": 2 }
}
```

---

### 2. Detail Grade Barang

```
GET /api/grade-barang/{id}
```

**Response:** Single object grade barang.

---

### 3. Tambah Grade Barang

```
POST /api/grade-barang
```

**Request Body:**

```json
{
  "kode": "A",
  "nama": "Grade A"
}
```

| Field | Tipe | Wajib | Validasi |
|---|---|---|---|
| `kode` | string | ✅ | Unique di `ref_grade_barang` |
| `nama` | string | ✅ | - |

**Response Sukses:**

```json
{
  "success": true,
  "message": "Data berhasil ditambahkan",
  "data": { "id": 1, "kode": "A", "nama": "Grade A" }
}
```

---

### 4. Update Grade Barang

```
PUT /api/grade-barang/{id}
PATCH /api/grade-barang/{id}
```

**Request Body:** Sama dengan store. Validasi `kode` unique kecuali untuk record sendiri.

---

### 5. Soft Delete

```
DELETE /api/grade-barang/{id}/soft
```

Menandai data sebagai dihapus (soft delete).

---

### 6. Restore

```
PATCH /api/grade-barang/{id}/restore
```

Mengembalikan data yang sudah di-soft delete.

---

### 7. Force Delete

```
DELETE /api/grade-barang/{id}/force
```

Menghapus data secara permanen. Gagal jika data masih digunakan oleh data lain (FK constraint → error `409`).

---

### 8. List With Trashed

```
GET /api/grade-barang/with-trashed/all
```

Menampilkan semua data termasuk yang di-soft delete.

---

### 9. List Trashed Only

```
GET /api/grade-barang/with-trashed/trashed
```

Menampilkan hanya data yang di-soft delete.

---

## File Terkait

| File | Keterangan |
|---|---|
| `app/Http/Controllers/MasterData/GradeBarangController.php` | Controller |
| `app/Models/MasterData/GradeBarang.php` | Model |
| `routes/api.php` | Route definitions (line 186-200) |
