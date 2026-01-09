# 📱 Panduan Lengkap Google Play In-App Purchase

## 📋 Daftar Isi
1. [Persiapan](#persiapan)
2. [Build & Upload APK](#build--upload-apk)
3. [Setup Google Play Console](#setup-google-play-console)
4. [Implementasi Kode](#implementasi-kode)
5. [Testing](#testing)
6. [Troubleshooting](#troubleshooting)

---

## 1. Persiapan

### ✅ Checklist Persiapan
- [x] Package `in_app_purchase` sudah ditambahkan
- [ ] Google Play Developer Account aktif
- [ ] Aplikasi sudah terdaftar di Google Play Console
- [ ] Merchant account sudah di-setup (untuk terima pembayaran)

### 📦 Dependencies (Sudah Ditambahkan)
```yaml
dependencies:
  in_app_purchase: ^3.1.13
  in_app_purchase_android: ^0.3.4+3
```

---

## 2. Build & Upload APK

### Step 1: Build Release APK

```bash
# Di terminal project
flutter build apk --release
```

APK akan tersimpan di:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Step 2: Upload ke Google Play Console

1. Buka [Google Play Console](https://play.google.com/console)
2. Pilih aplikasi "Ingat.in"
3. Sidebar: **Testing → Internal testing**
4. Klik **Create new release**
5. Upload `app-release.apk`
6. Isi Release notes (contoh: "Initial release with IAP support")
7. Klik **Save** → **Review release** → **Start rollout to Internal testing**

### Step 3: Tambah Testers

1. Di halaman Internal testing
2. Tab **Testers**
3. Klik **Create email list**
4. Nama: "IAP Testers"
5. Tambahkan email Anda
6. **Save**

⏱️ **Tunggu ~15-30 menit** untuk APK diproses

---

## 3. Setup Google Play Console

### Step 1: Buat Produk In-App

1. Sidebar: **Monetization → In-app products**
2. Klik **Create product** (3x untuk 3 produk)

#### Produk 1: 10 Slot Looping
- **Product ID**: `looping_10_slots`
- **Name**: 10 Slot Looping
- **Description**: Tambah 10 slot untuk reminder looping
- **Status**: Active
- **Price**: 
  - Default price: Rp 15.000
  - Pilih negara: Indonesia
  - Set harga: 15000

#### Produk 2: 20 Slot Looping
- **Product ID**: `looping_20_slots`
- **Name**: 20 Slot Looping
- **Description**: Tambah 20 slot untuk reminder looping
- **Status**: Active
- **Price**: Rp 25.000

#### Produk 3: 50 Slot Looping
- **Product ID**: `looping_50_slots`
- **Name**: 50 Slot Looping
- **Description**: Tambah 50 slot untuk reminder looping
- **Status**: Active
- **Price**: Rp 50.000

### Step 2: Activate Products

Untuk setiap produk:
1. Klik produk
2. Tab **Pricing**
3. Pastikan status **Active**
4. **Save**

---

## 4. Implementasi Kode

### File 1: `lib/services/iap_service.dart`

```dart
import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

class IAPService {
  static final InAppPurchase _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  // Product IDs
  static const String product10Slots = 'looping_10_slots';
  static const String product20Slots = 'looping_20_slots';
  static const String product50Slots = 'looping_50_slots';
  
  static const Set<String> _productIds = {
    product10Slots,
    product20Slots,
    product50Slots,
  };

  // Initialize IAP
  static Future<bool> initialize() async {
    final available = await _iap.isAvailable();
    if (!available) {
      print('IAP not available');
      return false;
    }
    
    // Listen to purchase updates
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => print('Purchase error: $error'),
    );
    
    return true;
  }

  // Fetch products from Google Play
  static Future<List<ProductDetails>> getProducts() async {
    final response = await _iap.queryProductDetails(_productIds);
    
    if (response.error != null) {
      print('Error fetching products: ${response.error}');
      return [];
    }
    
    return response.productDetails;
  }

  // Purchase a product
  static Future<bool> purchaseProduct(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    
    try {
      final success = await _iap.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );
      return success;
    } catch (e) {
      print('Purchase error: $e');
      return false;
    }
  }

  // Handle purchase updates
  static void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        // Purchase successful
        _handleSuccessfulPurchase(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        // Purchase error
        print('Purchase error: ${purchase.error}');
      }
      
      // Complete purchase
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  // Handle successful purchase
  static void _handleSuccessfulPurchase(PurchaseDetails purchase) {
    print('Purchase successful: ${purchase.productID}');
    // This will be handled by the stream listener in premium_page.dart
  }

  // Restore purchases
  static Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  // Dispose
  static void dispose() {
    _subscription?.cancel();
  }
}
```

### File 2: Update `lib/services/premium_service.dart`

Tambahkan method baru:

```dart
// Add slots from IAP purchase
static Future<void> addSlotsFromPurchase({
  required String productId,
  required String transactionId,
}) async {
  int slotsToAdd = 0;
  
  // Determine slots based on product ID
  switch (productId) {
    case 'looping_10_slots':
      slotsToAdd = 10;
      break;
    case 'looping_20_slots':
      slotsToAdd = 20;
      break;
    case 'looping_50_slots':
      slotsToAdd = 50;
      break;
  }
  
  if (slotsToAdd > 0) {
    await purchaseSlots(
      productId: productId,
      slotsToAdd: slotsToAdd,
      paymentMethod: 'google_play',
      transactionId: transactionId,
    );
  }
}
```

### File 3: Update `lib/pages/premium_page.dart`

Tambahkan di bagian atas class:

```dart
import '../services/iap_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

// Di initState
@override
void initState() {
  super.initState();
  _initIAP();
}

Future<void> _initIAP() async {
  await IAPService.initialize();
  final products = await IAPService.getProducts();
  setState(() {
    _products = products;
  });
  
  // Listen to purchase stream
  InAppPurchase.instance.purchaseStream.listen((purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        _handlePurchaseSuccess(purchase);
      }
    }
  });
}

void _handlePurchaseSuccess(PurchaseDetails purchase) async {
  await PremiumService.addSlotsFromPurchase(
    productId: purchase.productID,
    transactionId: purchase.purchaseID ?? '',
  );
  
  // Refresh UI
  ref.invalidate(totalLoopingSlotsProvider);
  ref.invalidate(slotInfoProvider);
  
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pembelian berhasil!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
```

Update method `_showPurchaseDialog`:

```dart
void _showPurchaseDialog(
  BuildContext context,
  String title,
  String price,
  int slots,
  String productId,
) {
  // Find product from Google Play
  final product = _products.firstWhere(
    (p) => p.id == productId,
    orElse: () => null,
  );
  
  if (product == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk tidak tersedia')),
    );
    return;
  }
  
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Konfirmasi Pembelian'),
      content: Text(
        'Anda akan membeli:\n\n'
        '$title\n'
        'Harga: ${product.price}\n\n'
        'Lanjutkan ke pembayaran?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(dialogContext);
            
            // Show loading
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => const Center(
                child: CircularProgressIndicator(),
              ),
            );
            
            // Purchase
            await IAPService.purchaseProduct(product);
            
            // Close loading
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text('Beli'),
        ),
      ],
    ),
  );
}
```

---

## 5. Testing

### Step 1: Install dari Internal Testing

1. Buka link Internal Testing dari Google Play Console
2. Accept invitation
3. Install aplikasi dari Play Store (bukan dari Flutter)

### Step 2: Test Purchase Flow

1. Buka aplikasi
2. Masuk ke Premium Page
3. Pilih paket (misal: 10 Slot)
4. Tap "Beli"
5. Google Play payment sheet muncul
6. Login dengan akun tester
7. Confirm payment (akan gratis untuk tester)
8. Verify slot bertambah

### Step 3: Test Restore Purchases

1. Uninstall aplikasi
2. Install ulang
3. Buka Premium Page
4. Tap "Restore Purchases" (jika ada button)
5. Verify slot kembali

---

## 6. Troubleshooting

### Error: "Item not available"
- Pastikan produk sudah Active di Google Play Console
- Tunggu 15-30 menit setelah aktivasi produk
- Pastikan APK sudah di-upload dan diproses

### Error: "Authentication required"
- Login dengan akun yang terdaftar sebagai tester
- Pastikan akun sudah accept invitation

### Purchase tidak muncul
- Check Firestore untuk transaction record
- Check log untuk error messages
- Verify purchase stream listener berjalan

### Harga tidak muncul
- Pastikan `getProducts()` dipanggil saat init
- Check response dari `queryProductDetails`
- Verify product IDs match dengan Google Play Console

---

## 📝 Checklist Final

### Google Play Console
- [ ] APK uploaded ke Internal Testing
- [ ] 3 produk in-app sudah dibuat dan Active
- [ ] Harga sudah di-set untuk setiap produk
- [ ] Email tester sudah ditambahkan

### Kode
- [ ] `IAPService` sudah dibuat
- [ ] `PremiumService.addSlotsFromPurchase` sudah ditambahkan
- [ ] `PremiumPage` sudah diupdate dengan IAP
- [ ] Purchase stream listener sudah di-setup

### Testing
- [ ] Install dari Internal Testing link
- [ ] Test purchase flow
- [ ] Verify slot bertambah
- [ ] Check Firestore records
- [ ] Test dengan akun tester

---

## 🚀 Next Steps

Setelah testing berhasil:
1. Upload ke Production
2. Submit untuk review
3. Tunggu approval (~1-3 hari)
4. Aplikasi live di Play Store!

---

## 💡 Tips

- **Testing**: Selalu test dengan akun tester, bukan production
- **Prices**: Harga di Google Play Console yang digunakan, bukan hardcode
- **Verification**: Untuk production, implement server-side verification
- **Logs**: Selalu check logs untuk debug
- **Firestore**: Simpan semua transaction untuk audit trail
