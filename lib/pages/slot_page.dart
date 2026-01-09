import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../providers/premium_provider.dart';
import '../services/slot_service.dart';

class SlotPage extends ConsumerStatefulWidget {
  const SlotPage({super.key});

  @override
  ConsumerState<SlotPage> createState() => _SlotPageState();
}

class _SlotPageState extends ConsumerState<SlotPage> {
  List<ProductDetails> _products = [];
  bool _loading = true;
  bool _purchasing = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    // Simulate delay for realistic feel
    await Future.delayed(const Duration(seconds: 1));
    final products = await SlotService.getAvailableProducts();
    if (mounted) {
      setState(() {
        _products = products;
        _loading = false;
      });
    }
  }

  Future<void> _purchaseProduct(ProductDetails product) async {
    if (_purchasing) return;
    
    setState(() => _purchasing = true);
    
    try {
      final success = await SlotService.purchaseProduct(product);
      
      if (mounted) {
        if (success) {
          // Invalidate providers to refresh data
          ref.invalidate(totalLoopingSlotsProvider);
          ref.invalidate(slotInfoProvider);
          ref.invalidate(remainingLoopingSlotsProvider);
          ref.invalidate(canAddLoopingReminderProvider);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pembelian berhasil! Slot Anda telah ditambahkan.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pembelian gagal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _purchasing = false);
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _purchasing = true);
    
    try {
      await SlotService.restorePurchases();
      
      if (mounted) {
        // Refresh data
        ref.invalidate(totalLoopingSlotsProvider);
        ref.invalidate(slotInfoProvider);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembelian berhasil dipulihkan!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memulihkan pembelian: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _purchasing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final slotInfoAsync = ref.watch(slotInfoProvider);
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          context.go('/');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Slot Plus'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.restore),
              tooltip: 'Pulihkan Pembelian',
              onPressed: _purchasing ? null : _restorePurchases,
            ),
          ],
        ),
        body: slotInfoAsync.when(
          data: (slotInfo) {
            final total = slotInfo['total']!;
            final used = slotInfo['used']!;
            final remaining = slotInfo['remaining']!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Slot Usage Card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sisa Slot Looping',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '$remaining',
                                    style: theme.textTheme.displayMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.loop,
                                  size: 32,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          LinearProgressIndicator(
                            value: total > 0 ? used / total : 0,
                            minHeight: 12,
                            backgroundColor: Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Terpakai: $used', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('Total: $total', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info
                  Text(
                    '💡 Informasi',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            icon: Icons.check_circle,
                            text: 'Reminder biasa: Tanpa batas',
                            color: Colors.green,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            icon: Icons.loop,
                            text: 'Reminder looping: Terbatas slot',
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            icon: Icons.star,
                            text: 'Gratis: 10 slot looping',
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Premium Packages
                  Text(
                    '🎁 Paket Slot Plus',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_products.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 48,
                              color: Colors.orange,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Produk belum tersedia',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Produk slot akan tersedia setelah aplikasi dipublikasikan di Play Store.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _loadProducts,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._products.asMap().entries.map((entry) {
                      final index = entry.key;
                      final product = entry.value;
                      
                      // Determine slots based on product ID
                      int slots = 0;
                      Color color = Colors.blue;
                      bool isPopular = false;
                      
                      if (product.id == SlotService.slot10ProductId) {
                        slots = 10;
                        color = Colors.blue;
                      } else if (product.id == SlotService.slot20ProductId) {
                        slots = 20;
                        color = Colors.purple;
                        isPopular = true;
                      } else if (product.id == SlotService.slot50ProductId) {
                        slots = 50;
                        color = Colors.orange;
                      }
                      
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < _products.length - 1 ? 12 : 0,
                        ),
                        child: _buildProductCard(
                          product: product,
                          slots: slots,
                          color: color,
                          isPopular: isPopular,
                        ),
                      );
                    }).toList(),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text),
        ),
      ],
    );
  }

  Widget _buildProductCard({
    required ProductDetails product,
    required int slots,
    required Color color,
    bool isPopular = false,
  }) {
    return Card(
      elevation: isPopular ? 6 : 2,
      child: InkWell(
        onTap: _purchasing ? null : () => _showPurchaseDialog(product, slots),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isPopular ? Border.all(color: color, width: 2) : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.card_giftcard,
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isPopular)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'POPULER',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (isPopular) const SizedBox(height: 4),
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+$slots slot looping',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      product.price,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPurchaseDialog(ProductDetails product, int slots) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Pembelian'),
        content: Text(
          'Anda akan membeli:\n\n'
          '${product.title}\n'
          'Harga: ${product.price}\n'
          '+$slots slot looping\n\n'
          'Pembayaran melalui Google Play Store.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _purchaseProduct(product);
            },
            child: const Text('Beli Sekarang'),
          ),
        ],
      ),
    );
  }
}
