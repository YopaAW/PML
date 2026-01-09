import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../services/backup_service.dart';
import '../services/local_storage_service.dart';

class CloudPage extends ConsumerStatefulWidget {
  const CloudPage({super.key});

  @override
  ConsumerState<CloudPage> createState() => _CloudPageState();
}

class _CloudPageState extends ConsumerState<CloudPage> {
  Map<String, int>? _dataInfo;
  DateTime? _lastSyncTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDataInfo();
  }

  Future<void> _loadDataInfo() async {
    final info = await BackupService.getDataInfo();
    final syncTime = await BackupService.getLastSyncTime();
    
    if (mounted) {
      setState(() {
        _dataInfo = info;
        _lastSyncTime = syncTime;
      });
    }
  }

  Future<void> _exportData() async {
    setState(() => _isLoading = true);
    
    try {
      await BackupService.exportAndShare();
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil di-export'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal export data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _importData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) return;

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();

      if (!mounted) return;

      // Show dialog to choose merge or replace
      final shouldMerge = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import Data'),
          content: const Text('Bagaimana cara mengimport data?\n\n'
              '• Gabung: Tambahkan ke data yang ada\n'
              '• Ganti: Hapus data lama dan ganti dengan data baru'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Gabung'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Ganti'),
            ),
          ],
        ),
      );

      if (shouldMerge == null) return;

      setState(() => _isLoading = true);

      await BackupService.importAndRestore(jsonString, merge: shouldMerge);
      await _loadDataInfo();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil di-import'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal import data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _manualSync() async {
    setState(() => _isLoading = true);

    try {
      await BackupService.manualSync();
      await _loadDataInfo();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil di-sync'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal sync data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final isGuest = user == null;

    return WillPopScope(
      onWillPop: () async {
        context.go('/');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cloud'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cloud Backup Section
                  if (isGuest) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cloud_off,
                              size: 64,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Cloud Backup Tidak Aktif',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Login untuk mengaktifkan backup cloud dan sinkronisasi otomatis',
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => context.go('/login'),
                              icon: const Icon(Icons.login),
                              label: const Text('Login Sekarang'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    Text(
                      '☁️ Cloud Backup',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            title: const Text('Auto Sync Aktif'),
                            subtitle: Text(
                              _lastSyncTime != null
                                  ? 'Last sync: ${_formatTime(_lastSyncTime!)}'
                                  : 'Syncing...',
                            ),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: Icon(
                              Icons.sync,
                              color: theme.colorScheme.primary,
                            ),
                            title: const Text('Sync Sekarang'),
                            subtitle: const Text('Force sync data ke cloud'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: _manualSync,
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: Icon(
                              Icons.cloud_download,
                              color: theme.colorScheme.primary,
                            ),
                            title: const Text('Load Data dari Cloud'),
                            subtitle: const Text('Ambil data terbaru dari cloud'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: _manualSync,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Export/Import Section
                  Text(
                    '📦 Export / Import',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.upload_file,
                            color: theme.colorScheme.primary,
                          ),
                          title: const Text('Export JSON'),
                          subtitle: const Text('Backup data ke file'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: _exportData,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.download,
                            color: theme.colorScheme.primary,
                          ),
                          title: const Text('Import JSON'),
                          subtitle: const Text('Restore data dari file'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: _importData,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Data Info Section
                  Text(
                    '📊 Data Info',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _dataInfo == null
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              children: [
                                _buildInfoRow(
                                  icon: Icons.notifications_active,
                                  label: 'Total Reminders',
                                  value: '${_dataInfo!['reminders']}',
                                  color: theme.colorScheme.primary,
                                ),
                                const Divider(),
                                _buildInfoRow(
                                  icon: Icons.category,
                                  label: 'Total Categories',
                                  value: '${_dataInfo!['categories']}',
                                  color: theme.colorScheme.secondary,
                                ),
                                const Divider(),
                                _buildInfoRow(
                                  icon: Icons.edit,
                                  label: 'Custom Categories',
                                  value: '${_dataInfo!['customCategories']}',
                                  color: Colors.orange,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit yang lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam yang lalu';
    } else {
      return '${diff.inDays} hari yang lalu';
    }
  }
}
