# Dokumentasi Perubahan Penambahan ID Rak

> Dokumen ini menjelaskan perubahan API terkait penambahan field `id_rak` pada fitur **Stock Opname**, **Stock Mutation**, dan **Purchase Order**. Silahkan disesuaikan oleh tim mobile.

---

## 📋 Overview

Field `id_rak` ditambahkan untuk melacak lokasi barang di rak gudang. Semua referensi `id_rak` mengacu pada tabel `ref_rak`.

### Tabel Referensi Rak (`ref_rak`)

| Field       | Type    | Description                  |
| ----------- | ------- | ---------------------------- |
| `id`        | integer | Primary key                  |
| `kode`      | string  | Kode unik rak                |
| `nama_rak`  | string  | Nama/deskripsi rak           |
| `gudang_id` | integer | FK ke ref_gudang             |
| `kapasitas` | integer | Kapasitas rak (opsional)     |

---

## 1. Stock Opname Detail

### Endpoint: Add Detail

```
POST /api/v1/stock-opname/{id}/detail
```

### Request Body

| Field        | Type    | Required | Description                   |
| ------------ | ------- | -------- | ----------------------------- |
| `kode_barang`| string  | ✅ Ya    | Kode barang dari ref_item_barang |
| `id_rak`     | integer | ✅ Ya    | ID rak tempat barang berada   |
| `stok_sistem`| integer | Tergantung| Wajib jika item frozen, null jika tidak |
| `stok_fisik` | integer | ✅ Ya    | Jumlah stok fisik yang dihitung |
| `catatan`    | string  | ❌ Tidak | Catatan opsional              |

### Contoh Request

```json
{
    "kode_barang": "BRG-001",
    "id_rak": 5,
    "stok_sistem": 100,
    "stok_fisik": 98,
    "catatan": "Selisih 2 unit"
}
```

### Response Body (Detail Object)

Pada response, field `id_rak` akan dikembalikan beserta relasi `rak` jika di-load:

```json
{
    "success": true,
    "message": "Detail stock opname berhasil ditambahkan",
    "data": {
        "id": 1,
        "stock_opname_id": 10,
        "item_barang_id": 25,
        "id_rak": 5,
        "stok_sistem": 100,
        "stok_fisik": 98,
        "catatan": "Selisih 2 unit",
        "item_barang": { ... },
        "rak": {
            "id": 5,
            "kode": "RAK-A1",
            "nama_rak": "Rak A Lantai 1",
            "gudang_id": 1,
            "kapasitas": 500
        }
    }
}
```

### Model Relationship

```php
// StockOpnameDetail.php
public function rak()
{
    return $this->belongsTo(Rak::class, 'id_rak');
}
```

---

## 2. Stock Mutation

### Endpoint: Create Stock Mutation

```
POST /api/v1/stock-mutation
```

### Request Body

| Field                              | Type    | Required | Description                          |
| ---------------------------------- | ------- | -------- | ------------------------------------ |
| `gudang_asal_id`                   | integer | ✅ Ya    | ID gudang asal                       |
| `gudang_tujuan_id`                 | integer | ✅ Ya    | ID gudang tujuan                     |
| `stock_mutation`                   | array   | ✅ Ya    | Array item mutasi                    |
| `stock_mutation.*.item_barang_id`  | integer | ✅ Ya    | ID item barang                       |
| `stock_mutation.*.id_rak_asal`     | integer | ✅ Ya    | ID rak asal (tempat barang diambil)  |
| `stock_mutation.*.id_rak_tujuan`   | integer | ✅ Ya    | ID rak tujuan (tempat barang ditaruh)|
| `stock_mutation.*.unit`            | string  | ✅ Ya    | Unit: `single` atau `bulk`           |
| `stock_mutation.*.quantity`        | numeric | ✅ Ya    | Jumlah barang yang dimutasi          |

### Contoh Request

```json
{
    "gudang_asal_id": 1,
    "gudang_tujuan_id": 2,
    "stock_mutation": [
        {
            "item_barang_id": 10,
            "id_rak_asal": 3,
            "id_rak_tujuan": 8,
            "unit": "single",
            "quantity": 50
        },
        {
            "item_barang_id": 15,
            "id_rak_asal": 4,
            "id_rak_tujuan": 9,
            "unit": "bulk",
            "quantity": 100
        }
    ]
}
```

### Response Body (Stock Mutation Item Object)

```json
{
    "success": true,
    "message": "Stock Mutation berhasil ditambahkan",
    "data": {
        "id": 1,
        "nomor_mutasi": "MTG-2026-0001",
        "gudang_asal_id": 1,
        "gudang_tujuan_id": 2,
        "status": "requested",
        "stock_mutation_items": [
            {
                "id": 1,
                "stock_mutation_id": 1,
                "item_barang_id": 10,
                "id_rak_asal": 3,
                "id_rak_tujuan": 8,
                "unit": "single",
                "quantity": 50,
                "rak_asal": {
                    "id": 3,
                    "kode": "RAK-A1",
                    "nama_rak": "Rak A Lantai 1"
                },
                "rak_tujuan": {
                    "id": 8,
                    "kode": "RAK-B2",
                    "nama_rak": "Rak B Lantai 2"
                }
            }
        ]
    }
}
```

### Model Relationships

```php
// StockMutationItem.php
public function rakAsal()
{
    return $this->belongsTo(Rak::class, 'id_rak_asal');
}

public function rakTujuan()
{
    return $this->belongsTo(Rak::class, 'id_rak_tujuan');
}
```

---

## 3. Purchase Order Item

### Endpoint: Create Purchase Order

```
POST /api/v1/purchase-order
```

### Request Body

| Field                 | Type    | Required | Description                             |
| --------------------- | ------- | -------- | --------------------------------------- |
| `tanggal_po`          | date    | ❌ Tidak | Tanggal PO (default: hari ini)          |
| `tanggal_jatuh_tempo` | date    | ✅ Ya    | Tanggal jatuh tempo                     |
| `id_supplier`         | integer | ✅ Ya    | ID supplier                             |
| `items`               | array   | ❌ Tidak | Array item PO                           |
| `items.*.qty`         | integer | ✅ Ya    | Quantity                                |
| `items.*.panjang`     | numeric | ✅ Ya    | Panjang barang                          |
| `items.*.lebar`       | numeric | ❌ Tidak | Lebar barang (nullable)                 |
| `items.*.tebal`       | numeric | ✅ Ya    | Tebal barang                            |
| `items.*.jenis_barang_id`  | integer | ✅ Ya | ID jenis barang                        |
| `items.*.bentuk_barang_id` | integer | ✅ Ya | ID bentuk barang                       |
| `items.*.grade_barang_id`  | integer | ✅ Ya | ID grade barang                        |
| `items.*.harga`       | numeric | ✅ Ya    | Harga per item                          |
| `items.*.satuan`      | string  | ❌ Tidak | Satuan (default: PCS)                   |
| `items.*.diskon`      | numeric | ❌ Tidak | Diskon dalam persen                     |
| `items.*.catatan`     | string  | ❌ Tidak | Catatan item                            |
| `items.*.id_rak`      | integer | ❌ Tidak | ID rak tempat barang akan ditempatkan   |

> **Note**: Field `id_rak` bersifat **nullable/opsional**. Digunakan untuk menentukan lokasi rak tempat barang akan ditempatkan setelah diterima.

### Contoh Request

```json
{
    "tanggal_jatuh_tempo": "2026-02-01",
    "id_supplier": 5,
    "items": [
        {
            "qty": 100,
            "panjang": 200,
            "lebar": 100,
            "tebal": 2.5,
            "jenis_barang_id": 1,
            "bentuk_barang_id": 2,
            "grade_barang_id": 1,
            "harga": 50000,
            "satuan": "PCS",
            "diskon": 5,
            "catatan": "Urgent order",
            "id_rak": 10
        }
    ]
}
```

### Response Body (Purchase Order Item Object)

```json
{
    "success": true,
    "message": "Purchase Order berhasil ditambahkan",
    "data": {
        "id": 1,
        "nomor_po": "PO-2026-0001",
        "items": [
            {
                "id": 1,
                "purchase_order_id": 1,
                "qty": 100,
                "panjang": 200,
                "lebar": 100,
                "tebal": 2.5,
                "harga": 50000,
                "satuan": "PCS",
                "diskon": 5,
                "catatan": "Urgent order",
                "id_rak": 10,
                "rak": {
                    "id": 10,
                    "kode": "RAK-C3",
                    "nama_rak": "Rak C Lantai 3",
                    "gudang_id": 1
                }
            }
        ]
    }
}
```

### Model Relationship

```php
// PurchaseOrderItem.php
public function rak()
{
    return $this->belongsTo(Rak::class, 'id_rak');
}
```

---

## 4. Penerimaan Barang Detail

### Endpoint: Create Penerimaan Barang

```
POST /api/v1/penerimaan-barang
```

### Request Body

| Field                         | Type    | Required | Description                                |
| ----------------------------- | ------- | -------- | ------------------------------------------ |
| `asal_penerimaan`             | string  | ✅ Ya    | Asal penerimaan: `purchaseorder` atau `stockmutation` |
| `nomor_po`                    | string  | Kondisional | Wajib jika asal_penerimaan = `purchaseorder` |
| `nomor_mutasi`                | string  | Kondisional | Wajib jika asal_penerimaan = `stockmutation` |
| `gudang_id`                   | integer | ✅ Ya    | ID gudang tujuan                           |
| `catatan`                     | string  | ❌ Tidak | Catatan penerimaan                         |
| `bukti_foto`                  | string  | ❌ Tidak | Foto bukti dalam format base64             |
| `detail_barang`               | array   | ✅ Ya    | Array detail barang yang diterima (min: 1) |
| `detail_barang.*.id`          | integer | ✅ Ya    | ID item barang                             |
| `detail_barang.*.kode`        | string  | ✅ Ya    | Kode barang                                |
| `detail_barang.*.nama_item`   | string  | ✅ Ya    | Nama item                                  |
| `detail_barang.*.ukuran`      | string  | ✅ Ya    | Ukuran barang                              |
| `detail_barang.*.qty`         | numeric | ✅ Ya    | Quantity yang diterima                     |
| `detail_barang.*.status_scan` | string  | ✅ Ya    | Status scan barang                         |
| `detail_barang.*.id_rak`      | integer | ✅ Ya    | ID rak tempat barang ditempatkan           |

> **Note**: Field `id_rak` bersifat **required** pada setiap item di `detail_barang`. Rak harus valid dan ada di tabel `ref_rak`.

### Contoh Request

```json
{
    "asal_penerimaan": "purchaseorder",
    "nomor_po": "PO-2026-0001",
    "gudang_id": 1,
    "catatan": "Penerimaan barang dari supplier A",
    "bukti_foto": "data:image/jpeg;base64,/9j/4AAQSkZJRg...",
    "detail_barang": [
        {
            "id": 25,
            "kode": "BRG-001",
            "nama_item": "Besi Siku 6x6",
            "ukuran": "6x200x6",
            "qty": 50,
            "status_scan": "scanned",
            "id_rak": 5
        },
        {
            "id": 30,
            "kode": "BRG-002",
            "nama_item": "Plat Besi 2mm",
            "ukuran": "2x100x200",
            "qty": 100,
            "status_scan": "scanned",
            "id_rak": 6
        }
    ]
}
```

### Response Body (Penerimaan Barang Object)

```json
{
    "success": true,
    "message": "Penerimaan barang berhasil disimpan",
    "data": {
        "id": 1,
        "origin": "purchaseorder",
        "id_purchase_order": 1,
        "id_stock_mutation": null,
        "id_gudang": 1,
        "catatan": "Penerimaan barang dari supplier A",
        "url_foto": "/storage/penerimaan-barang/1/bukti_foto.jpg",
        "details": [
            {
                "id": 1,
                "id_penerimaan_barang": 1,
                "id_item_barang": 25,
                "id_rak": 5,
                "qty": 50,
                "rak": {
                    "id": 5,
                    "kode": "RAK-A1",
                    "nama_rak": "Rak A Lantai 1",
                    "gudang_id": 1,
                    "kapasitas": 500
                }
            },
            {
                "id": 2,
                "id_penerimaan_barang": 1,
                "id_item_barang": 30,
                "id_rak": 6,
                "qty": 100,
                "rak": {
                    "id": 6,
                    "kode": "RAK-A2",
                    "nama_rak": "Rak A Lantai 2",
                    "gudang_id": 1,
                    "kapasitas": 500
                }
            }
        ]
    }
}
```

### Model Relationship

```php
// PenerimaanBarangDetail.php
public function rak()
{
    return $this->belongsTo(Rak::class, 'id_rak');
}
```

### Additional Endpoint: Get by Rak

```
GET /api/v1/penerimaan-barang/by-rak/{id_rak}
```

Endpoint ini dapat digunakan untuk mendapatkan semua penerimaan barang yang ada di rak tertentu.

---

## 📊 Ringkasan Perubahan Database

| Tabel                         | Kolom Baru         | Tipe Data          | Nullable | FK Reference |
| ----------------------------- | ------------------ | ------------------ | -------- | ------------ |
| `trx_stock_opname_detail`     | `id_rak`           | unsignedBigInteger | ❌ No    | `ref_rak.id` |
| `trx_stock_mutation_detail`   | `id_rak_asal`      | unsignedBigInteger | ✅ Yes   | `ref_rak.id` |
| `trx_stock_mutation_detail`   | `id_rak_tujuan`    | unsignedBigInteger | ✅ Yes   | `ref_rak.id` |
| `trx_purchase_order_item`     | `id_rak`           | unsignedBigInteger | ✅ Yes   | `ref_rak.id` |
| `trx_penerimaan_barang_detail`| `id_rak`           | unsignedBigInteger | ✅ Yes   | `ref_rak.id` |

---

## 🔗 API Endpoint untuk Master Rak

Untuk mendapatkan daftar rak, gunakan endpoint:

```
GET /api/v1/rak
```

Atau untuk mendapatkan rak berdasarkan gudang:

```
GET /api/v1/rak?gudang_id={id_gudang}
```

---

## ⚠️ Catatan Penting

1. **Stock Opname**: Field `id_rak` bersifat **required** saat menambahkan detail stock opname.

2. **Stock Mutation**: Field `id_rak_asal` dan `id_rak_tujuan` bersifat **required** saat membuat mutasi stok baru.

3. **Purchase Order**: Field `id_rak` bersifat **nullable/opsional**. Dapat diisi saat penerimaan barang untuk menentukan lokasi penempatan.

4. **Penerimaan Barang**: Field `id_rak` bersifat **required** pada setiap item di `detail_barang`. Field ini menentukan lokasi rak tempat barang akan ditempatkan setelah diterima.

5. **Validasi**: Sistem akan memvalidasi bahwa `id_rak` yang dikirim benar-benar ada di tabel `ref_rak` (`exists:ref_rak,id`).

6. **On Delete Behavior**: Semua foreign key menggunakan `onDelete('restrict')`, artinya rak tidak dapat dihapus jika masih ada data yang mereferensinya.

---

*Dokumentasi dibuat: 18 Januari 2026*
