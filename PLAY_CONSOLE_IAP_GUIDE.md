# Panduan Lengkap: Membuat Produk IAP di Google Play Console

## 📋 Persiapan

### Yang Harus Sudah Dilakukan:
- ✅ Upload AAB ke Internal Testing track
- ✅ AAB sudah dalam status "Available to testers"
- ✅ Punya akses ke Google Play Console

---

## 🎯 Step-by-Step: Membuat Produk IAP

### STEP 1: Akses Menu In-App Products

1. **Login ke Play Console**
   - Buka: https://play.google.com/console
   - Login dengan akun developer

2. **Pilih Aplikasi**
   - Klik aplikasi **Ingat.in** dari dashboard

3. **Buka Menu Monetize**
   - Sidebar kiri → **Monetize**
   - Klik **In-app products**

4. **Klik Create Product**
   - Tombol di kanan atas: **Create product**

---

### STEP 2: Buat Produk Slot #1 (10 Slot)

#### 2.1 Product Details

**Product ID**:
```
looping_slot_10
```
> ⚠️ **PENTING**: Product ID harus PERSIS sama dengan kode!
> Tidak bisa diubah setelah dibuat!

Klik **Create** setelah masukkan Product ID.

#### 2.2 Product Information

**Name** (Nama yang dilihat user):
```
10 Slot Looping
```

**Description** (Deskripsi produk):
```
Tambah 10 slot untuk reminder berulang. Buat lebih banyak pengingat yang otomatis berulang setiap hari, minggu, atau bulan.
```

#### 2.3 Pricing & Distribution

1. **Set Price**
   - Klik **Set price**
   - Pilih **Indonesia** dari dropdown
   - Masukkan harga: `15000` (Rp 15.000)
   - Klik **Apply prices**

2. **Distribution**
   - Centang semua negara atau pilih Indonesia saja
   - Klik **Save**

#### 2.4 Activate Product

1. Scroll ke atas
2. Toggle **Status** dari "Inactive" ke **Active**
3. Klik **Save** di kanan atas

✅ **Produk 1 selesai!**

---

### STEP 3: Buat Produk Slot #2 (20 Slot)

Ulangi STEP 2 dengan data:

**Product ID**: `looping_slot_20`
**Name**: `20 Slot Looping`
**Description**: 
```
Tambah 20 slot untuk reminder berulang. Paket hemat untuk pengguna aktif yang butuh banyak pengingat otomatis.
```
**Price**: `25000` (Rp 25.000)
**Status**: **Active**

---

### STEP 4: Buat Produk Slot #3 (50 Slot)

**Product ID**: `looping_slot_50`
**Name**: `50 Slot Looping`
**Description**: 
```
Tambah 50 slot untuk reminder berulang. Paket terbaik untuk power user dengan kebutuhan pengingat maksimal.
```
**Price**: `50000` (Rp 50.000)
**Status**: **Active**

---

### STEP 5: Buat Produk Donasi #1 (Cemilan)

#### 5.1 Product Details

**Product ID**: `donation_1k`

#### 5.2 Product Information

**Name**: `Donasi Cemilan`
**Description**: 
```
Traktir kami cemilan untuk teman ngoding. Terima kasih atas dukungannya!
```

#### 5.3 Pricing

**Price**: `1000` (Rp 1.000)

#### 5.4 ⚠️ PENTING: Set as Consumable

1. Scroll ke bagian **Product type**
2. Centang: ☑️ **Consumable**
   - Ini memungkinkan user beli berulang kali
3. **Status**: **Active**
4. **Save**

---

### STEP 6: Buat Produk Donasi #2-6

Ulangi STEP 5 untuk produk donasi lainnya:

#### Donasi Es Teh
- **Product ID**: `donation_2k`
- **Name**: `Donasi Es Teh`
- **Description**: `Penyegar di siang hari untuk tim developer. Terima kasih!`
- **Price**: `2000`
- **Consumable**: ☑️ Yes
- **Status**: Active

#### Donasi Kopi
- **Product ID**: `donation_5k`
- **Name**: `Donasi Kopi Hitam`
- **Description**: `Traktir kami secangkir kopi hitam untuk semangat coding. Terima kasih!`
- **Price**: `5000`
- **Consumable**: ☑️ Yes
- **Status**: Active

#### Donasi Makan Siang
- **Product ID**: `donation_10k`
- **Name**: `Donasi Makan Siang`
- **Description**: `Bantu kami tetap bertenaga dengan makan siang. Terima kasih banyak!`
- **Price**: `10000`
- **Consumable**: ☑️ Yes
- **Status**: Active

#### Donasi Server
- **Product ID**: `donation_20k`
- **Name**: `Donasi Server`
- **Description**: `Bantu biaya operasional server agar aplikasi tetap berjalan lancar. Terima kasih!`
- **Price**: `20000`
- **Consumable**: ☑️ Yes
- **Status**: Active

#### Donasi Sultan
- **Product ID**: `donation_50k`
- **Name**: `Donasi Sultan`
- **Description**: `Dukungan luar biasa! Terima kasih atas kontribusi besarnya untuk pengembangan aplikasi.`
- **Price**: `50000`
- **Consumable**: ☑️ Yes
- **Status**: Active

---

## ✅ Checklist Semua Produk

Pastikan semua 9 produk sudah dibuat:

### Slot Products (Non-Consumable)
- [ ] `looping_slot_10` - Rp 15.000 - Active
- [ ] `looping_slot_20` - Rp 25.000 - Active
- [ ] `looping_slot_50` - Rp 50.000 - Active

### Donation Products (Consumable ☑️)
- [ ] `donation_1k` - Rp 1.000 - Active - Consumable
- [ ] `donation_2k` - Rp 2.000 - Active - Consumable
- [ ] `donation_5k` - Rp 5.000 - Active - Consumable
- [ ] `donation_10k` - Rp 10.000 - Active - Consumable
- [ ] `donation_20k` - Rp 20.000 - Active - Consumable
- [ ] `donation_50k` - Rp 50.000 - Active - Consumable

---

## 🔍 Verifikasi Produk

### Cara Cek Semua Produk:

1. **Kembali ke In-app products list**
   - Monetize → In-app products

2. **Pastikan terlihat 9 produk**
   - Semua status: **Active** (hijau)
   - 3 produk slot: Non-consumable
   - 6 produk donasi: Consumable

3. **Cek Detail Setiap Produk**
   - Klik nama produk
   - Verifikasi:
     - ✅ Product ID benar
     - ✅ Price benar
     - ✅ Status Active
     - ✅ Consumable setting benar (untuk donasi)

---

## ⏰ Waktu Propagasi

Setelah membuat produk:
- **Minimum**: 2 jam
- **Recommended**: 4-6 jam
- **Maximum**: 24 jam

> 💡 **Tip**: Buat semua produk sekarang, lalu tunggu beberapa jam sebelum testing.

---

## 🎯 Next Steps Setelah Buat Produk

### 1. Setup License Testing
- Play Console → **Setup** → **License testing**
- Tambah email Gmail Anda
- Save changes

### 2. Setup Internal Testing
- **Testing** → **Internal testing** → **Testers**
- Create email list
- Tambah email Gmail Anda
- Copy opt-in URL

### 3. Opt-in sebagai Tester
- Buka opt-in URL di browser
- Login dengan email tester
- Klik "Become a tester"

### 4. Install dari Play Store
- Buka Play Store di HP
- Login dengan email tester
- Search "Ingat.in"
- Install

### 5. Test Pembelian
- Buka app → Slot Plus
- Pilih paket slot
- Klik beli
- **Pembelian akan GRATIS** (karena License Tester)

---

## ⚠️ Troubleshooting

### "Product ID already exists"
- Product ID harus unik
- Cek typo di Product ID
- Gunakan ID yang sudah ditentukan di panduan

### "Item not available for purchase"
- Tunggu 2-4 jam setelah aktivasi
- Clear Play Store cache
- Reinstall app dari Play Store

### "This version is not configured for billing"
- Pastikan AAB sudah di-upload
- Install HARUS dari Play Store
- Bukan dari APK manual

### Produk tidak muncul di app
- Cek Product ID di kode vs Console
- Pastikan status Active
- Tunggu propagasi time
- Restart app

---

## 📊 Monitoring

### Cek Order Management
- **Monetize** → **Order management**
- Lihat semua test purchases
- Status akan "Test" untuk License Testers

### Cek Financial Reports
- **Monetize** → **Financial reports**
- Test purchases tidak akan charged
- Production purchases akan muncul di sini

---

## ✅ Summary

Anda telah membuat:
- 3 produk slot (non-consumable)
- 6 produk donasi (consumable)
- Total 9 produk IAP
- Semua Active dan siap testing

**Next**: Setup License Testing dan install app dari Play Store untuk testing! 🚀
