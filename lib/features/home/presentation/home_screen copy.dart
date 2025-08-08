import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Import QR Scanner screen - make sure the path is correct
import 'qr_scanner_screen.dart'; // or the correct path to your QR scanner file

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Dummy data pemasangan SMARTI berdasarkan format real
  final List<Map<String, dynamic>> pemasanganList = [
    {
      'no': 1,
      'idSmarti': '20250111001',
      'imei': '867586070460845',
      'internet': '089514637125',
      'perumahan': 'PESONA KALIWUNGU INDAH',
      'kavling': 'A01, Protomulyo, Kaliwungu Selatan, Kab. Kendal',
      'status': 'completed',
      'statusText': 'Sudah Akad',
      'lastOnline': 'Minggu, 3 Agustus 2025 05.05.45 WIB',
      'tanggal': '2025-08-03',
      // Add missing fields that are used in the UI
      'namaPelanggan': 'John Doe',
      'id': '20250111001',
      'alamat': 'A01, Protomulyo, Kaliwungu Selatan, Kab. Kendal',
      'nomorMeter': '12345678901',
      'daya': '1300 VA',
    },
    {
      'no': 2,
      'idSmarti': '20250111002',
      'imei': '862990061421342',
      'internet': '089514637117',
      'perumahan': 'PESONA KALIWUNGU INDAH',
      'kavling': 'A02, Protomulyo, Kaliwungu Selatan, Kab. Kendal, Jawa Tengah',
      'status': 'completed',
      'statusText': 'Sudah Akad',
      'lastOnline': 'Minggu, 3 Agustus 2025 03.44.47 WIB',
      'tanggal': '2025-08-02',
      // Add missing fields
      'namaPelanggan': 'Jane Smith',
      'id': '20250111002',
      'alamat': 'A02, Protomulyo, Kaliwungu Selatan, Kab. Kendal, Jawa Tengah',
      'nomorMeter': '12345678902',
      'daya': '2200 VA',
    },
    {
      'no': 3,
      'idSmarti': '20250111003',
      'imei': '867586070460892',
      'internet': '089514637198',
      'perumahan': 'PESONA KALIWUNGU INDAH',
      'kavling': 'A03, Protomulyo, Kaliwungu Selatan, Kab. Kendal, Jawa Tengah',
      'status': 'in_progress',
      'statusText': 'Dalam Pemasangan',
      'lastOnline': '-',
      'tanggal': '2025-08-03',
      // Add missing fields
      'namaPelanggan': 'Bob Johnson',
      'id': '20250111003',
      'alamat': 'A03, Protomulyo, Kaliwungu Selatan, Kab. Kendal, Jawa Tengah',
      'nomorMeter': '12345678903',
      'daya': '1300 VA',
    },
    {
      'no': 4,
      'idSmarti': '20250111004',
      'imei': '867586070460899',
      'internet': '089514637201',
      'perumahan': 'TAMAN KENDAL ASRI',
      'kavling': 'B12, Kaliwungu Selatan, Kab. Kendal, Jawa Tengah',
      'status': 'pending',
      'statusText': 'Menunggu Pemasangan',
      'lastOnline': '-',
      'tanggal': '2025-08-03',
      // Add missing fields
      'namaPelanggan': 'Alice Brown',
      'id': '20250111004',
      'alamat': 'B12, Kaliwungu Selatan, Kab. Kendal, Jawa Tengah',
      'nomorMeter': '12345678904',
      'daya': '2200 VA',
    },
  ];

  int get totalPemasangan => pemasanganList.length;
  int get selesai =>
      pemasanganList.where((p) => p['status'] == 'completed').length;
  int get pending =>
      pemasanganList.where((p) => p['status'] == 'pending').length;
  int get inProgress =>
      pemasanganList.where((p) => p['status'] == 'in_progress').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMARTI Dashboard'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                // Refresh data
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data berhasil diperbarui'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Keluar Aplikasi'),
                      content: const Text('Yakin ingin logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
              );
              if (confirm ?? false) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          setState(() {
            // Refresh data
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan info petugas
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4CAF50).withOpacity(0.1),
                      const Color(0xFF4CAF50).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang, Petugas!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Pemasangan Device SMARTI',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'AKTIF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Statistik Pemasangan
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Total',
                      value: totalPemasangan.toString(),
                      icon: Icons.electrical_services,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Selesai',
                      value: selesai.toString(),
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Proses',
                      value: inProgress.toString(),
                      icon: Icons.sync,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Pending',
                      value: pending.toString(),
                      icon: Icons.schedule,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Tombol Scan QR Code
              Container(
                width: double.infinity,
                height: 80,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showQRScanner(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.qr_code_scanner, size: 32),
                  label: const Text(
                    'Scan QR Code Meteran PLN',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Header list pemasangan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar Pemasangan Hari Ini',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Navigate to full list
                    },
                    icon: const Icon(Icons.list_alt),
                    label: const Text('Lihat Semua'),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // List pemasangan
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pemasanganList.length,
                itemBuilder: (context, index) {
                  final pemasangan = pemasanganList[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          _showDetailPemasangan(context, pemasangan);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        pemasangan['status'],
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _getStatusIcon(pemasangan['status']),
                                      color: _getStatusColor(
                                        pemasangan['status'],
                                      ),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          pemasangan['namaPelanggan'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          'ID: ${pemasangan['id']}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        pemasangan['status'],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getStatusText(pemasangan['status']),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      pemasangan['alamat'],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.electric_meter,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Meter: ${pemasangan['nomorMeter']}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.flash_on,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    pemasangan['daya'],
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQRScanner(BuildContext context) {
    // Navigate to QR Scanner screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );
  }

  void _showDetailPemasangan(
    BuildContext context,
    Map<String, dynamic> pemasangan,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Detail Pemasangan SMARTI'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow('No', pemasangan['no'].toString()),
                  _DetailRow('ID SMARTI', pemasangan['idSmarti']),
                  _DetailRow('IMEI', pemasangan['imei']),
                  _DetailRow('Internet/SIM', pemasangan['internet']),
                  _DetailRow('Perumahan', pemasangan['perumahan']),
                  _DetailRow('Kavling', pemasangan['kavling']),
                  _DetailRow('Status', pemasangan['statusText']),
                  _DetailRow('Tanggal', pemasangan['tanggal']),
                  if (pemasangan['lastOnline'] != '-')
                    _DetailRow('Last Online', pemasangan['lastOnline']),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
              if (pemasangan['status'] != 'completed')
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Navigate to installation process
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Memulai proses pemasangan SMARTI ${pemasangan['idSmarti']}',
                        ),
                        backgroundColor: const Color(0xFF4CAF50),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.construction, size: 16),
                  label: const Text('Mulai Pemasangan'),
                ),
            ],
          ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'pending':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.sync;
      case 'pending':
        return Icons.schedule;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'SUDAH AKAD';
      case 'in_progress':
        return 'DALAM PEMASANGAN';
      case 'pending':
        return 'MENUNGGU PEMASANGAN';
      default:
        return 'UNKNOWN';
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
