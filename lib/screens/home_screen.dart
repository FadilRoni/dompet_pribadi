import 'package:flutter/material.dart';
import '../data_model.dart';
import 'kategori_screen.dart';
import 'akun_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nominalController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  String _pilihanTipe = "Pengeluaran";
  String _pilihanKategori = "";
  String _pilihanAkun = masterAkun.first;
  int _currentIndex = 0;
  String _filterAkun = "Semua";

  // Filter Tanggal Default: Bulan Juni 2026 (Menyesuaikan waktu saat ini)
  DateTime rangeMulai = DateTime(2026, 6, 1);
  DateTime rangeSelesai = DateTime(2026, 6, 30);

  void _editTransaksi(Transaksi item) {
    showDialog(
      context: context,
      builder: (context) {
        String editTipe = item.tipe;
        String editKategori = item.kategori;
        String editAkun = item.akun;
        final TextEditingController nominalEditController =
            TextEditingController(
              text: formatRibuan(item.nominal),
            );
        final TextEditingController catatanEditController =
            TextEditingController(text: item.catatan);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            List<String> kategoriAktif = masterKategori
                .where((k) => k.tipe == editTipe)
                .map((k) => k.nama)
                .toList();

            // Proteksi error jika list kosong atau data berubah
            if (kategoriAktif.isNotEmpty &&
                !kategoriAktif.contains(editKategori)) {
              editKategori = kategoriAktif.first;
            }

            return AlertDialog(
              title: Text("Edit Transaksi"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nominalEditController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [RibuanInputFormatter()],
                      decoration: InputDecoration(labelText: "Nominal (Rp)"),
                    ),
                    TextField(
                      controller: catatanEditController,
                      decoration: InputDecoration(
                        labelText: "Keterangan/Catatan",
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      value: editTipe,
                      decoration: InputDecoration(labelText: "Tipe"),
                      items: ["Pengeluaran", "Pemasukan"]
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          editTipe = val!;
                        });
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: editKategori.isEmpty ? null : editKategori,
                      decoration: InputDecoration(labelText: "Kategori"),
                      items: kategoriAktif
                          .map(
                            (k) => DropdownMenuItem(value: k, child: Text(k)),
                          )
                          .toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          editKategori = val!;
                        });
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: editAkun,
                      decoration: InputDecoration(
                        labelText: "Simpan/Ambil Dari",
                      ),
                      items: masterAkun
                          .map(
                            (a) => DropdownMenuItem(value: a, child: Text(a)),
                          )
                          .toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          editAkun = val!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nominalEditController.text.isNotEmpty) {
                      setState(() {
                        item.nominal =
                            double.tryParse(nominalEditController.text.replaceAll('.', '')) ?? 0;
                        item.catatan = catatanEditController.text;
                        item.tipe = editTipe;
                        item.kategori = editKategori;
                        item.akun = editAkun;
                      });
                      saveData();
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _hapusTransaksi(Transaksi item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Hapus Transaksi"),
          content: Text("Apakah Anda yakin ingin menghapus transaksi ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  daftarTransaksi.removeWhere((t) => t.id == item.id);
                });
                saveData();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text("Hapus"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Memilih kategori yang sesuai secara dinamis
    List<String> kategoriAktif = masterKategori
        .where((k) => k.tipe == _pilihanTipe)
        .map((k) => k.nama)
        .toList();

    // Proteksi error jika list kosong atau data berubah
    if (kategoriAktif.isNotEmpty && !kategoriAktif.contains(_pilihanKategori)) {
      _pilihanKategori = kategoriAktif.first;
    }

    // Filter data berdasarkan Range Tanggal, Akun, & Hitung Saldo Bersih, Pemasukan, Pengeluaran
    double totalPemasukan = 0;
    double totalPengeluaran = 0;

    // Proteksi filter akun jika akun dihapus dari masterAkun
    if (!["Semua", ...masterAkun].contains(_filterAkun)) {
      _filterAkun = "Semua";
    }

    List<Transaksi> riwayatTerfilter = daftarTransaksi.where((t) {
      bool masukRange =
          t.tanggal.isAfter(rangeMulai.subtract(Duration(days: 1))) &&
          t.tanggal.isBefore(rangeSelesai.add(Duration(days: 1)));
      
      bool masukAkun = _filterAkun == "Semua" || t.akun == _filterAkun;
      bool lolosFilter = masukRange && masukAkun;

      if (lolosFilter) {
        if (t.tipe == "Pemasukan") totalPemasukan += t.nominal;
        if (t.tipe == "Pengeluaran") totalPengeluaran += t.nominal;
      }
      return lolosFilter;
    }).toList();

    double totalSaldo = totalPemasukan - totalPengeluaran;

    String appBarTitle;
    Widget activeBody;

    if (_currentIndex == 0) {
      appBarTitle = "Catatan Keuangan Digital";
      activeBody = SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              margin: EdgeInsets.only(bottom: 15),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "TRANSAKSI",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _nominalController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [RibuanInputFormatter()],
                      decoration: InputDecoration(labelText: "Nominal (Rp)"),
                    ),
                    TextField(
                      controller: _catatanController,
                      decoration: InputDecoration(
                        labelText: "Keterangan/Catatan",
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      value: _pilihanTipe,
                      decoration: InputDecoration(labelText: "Tipe"),
                      items: ["Pengeluaran", "Pemasukan"]
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _pilihanTipe = val!),
                    ),
                    DropdownButtonFormField<String>(
                      value: _pilihanKategori.isEmpty ? null : _pilihanKategori,
                      decoration: InputDecoration(labelText: "Kategori"),
                      items: kategoriAktif
                          .map(
                            (k) => DropdownMenuItem(value: k, child: Text(k)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _pilihanKategori = val!),
                    ),
                    DropdownButtonFormField<String>(
                      value: _pilihanAkun,
                      decoration: InputDecoration(
                        labelText: "Simpan/Ambil Dari",
                      ),
                      items: masterAkun
                          .map(
                            (a) => DropdownMenuItem(value: a, child: Text(a)),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _pilihanAkun = val!),
                    ),
                    SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        if (_nominalController.text.isNotEmpty) {
                          setState(() {
                            daftarTransaksi.add(
                              Transaksi(
                                id: DateTime.now().toString(),
                                nominal:
                                    double.tryParse(_nominalController.text.replaceAll('.', '')) ??
                                    0,
                                catatan: _catatanController.text,
                                tipe: _pilihanTipe,
                                kategori: _pilihanKategori,
                                akun: _pilihanAkun,
                                tanggal: DateTime.now(),
                              ),
                            );
                            saveData();
                            _nominalController.clear();
                            _catatanController.clear();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text("Simpan Transaksi"),
                    ),
                  ],
                ),
              ),
            ),
            // FILTER RANGE TANGGAL
            Text(
              "FILTER PERIODE",
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: rangeMulai,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => rangeMulai = picked);
                  },
                  child: Text(
                    "Dari: ${rangeMulai.day}/${rangeMulai.month}/${rangeMulai.year}",
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: rangeSelesai,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => rangeSelesai = picked);
                  },
                  child: Text(
                    "Sampai: ${rangeSelesai.day}/${rangeSelesai.month}/${rangeSelesai.year}",
                  ),
                ),
              ],
            ),
            // FILTER BY AKUN
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Filter Akun: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: _filterAkun,
                  items: ["Semua", ...masterAkun].map((String val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Text(val),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _filterAkun = val!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            // RINGKASAN SALDO, PEMASUKAN, & PENGELUARAN
            Card(
              margin: EdgeInsets.symmetric(vertical: 10),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Pemasukan",
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Rp ${formatRibuan(totalPemasukan)}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.greenAccent,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        Column(
                          children: [
                            Text(
                              "Pengeluaran",
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Rp ${formatRibuan(totalPengeluaran)}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(height: 20),
                    Text(
                      "Saldo Bersih: Rp ${formatRibuan(totalSaldo)}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: totalSaldo >= 0
                            ? Colors.greenAccent
                            : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            // DAFTAR RIWAYAT
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: riwayatTerfilter.length,
              itemBuilder: (c, i) {
                final item = riwayatTerfilter[i];
                return ListTile(
                  title: Text("${item.catatan} (${item.kategori})"),
                  subtitle: Text(
                    "Akun: ${item.akun} | ${item.tanggal.day}/${item.tanggal.month}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${item.tipe == "Pengeluaran" ? "-" : "+"} Rp ${formatRibuan(item.nominal)}",
                        style: TextStyle(
                          color: item.tipe == "Pengeluaran"
                              ? Colors.red
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: () => _editTransaksi(item),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: () => _hapusTransaksi(item),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    } else if (_currentIndex == 1) {
      appBarTitle = "Kelola Master Kategori";
      activeBody = KategoriScreen();
    } else {
      appBarTitle = "Master Akun / Dompet";
      activeBody = AkunScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        automaticallyImplyLeading: false,
        actions: _currentIndex == 0
            ? [
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    final messenger = ScaffoldMessenger.of(context);
                    if (value == 'export') {
                      await exportData();
                      messenger.showSnackBar(
                        SnackBar(content: Text('Data berhasil diekspor!')),
                      );
                    } else if (value == 'import') {
                      bool success = await importData();
                      if (success) {
                        setState(() {}); // refresh UI
                        messenger.showSnackBar(
                          SnackBar(content: Text('Data berhasil diimpor!')),
                        );
                      } else {
                        messenger.showSnackBar(
                          SnackBar(content: Text('Gagal/Batal mengimpor data.')),
                        );
                      }
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: 'export',
                      child: Row(
                        children: [
                          Icon(Icons.upload, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Ekspor Data (Backup)'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'import',
                      child: Row(
                        children: [
                          Icon(Icons.download, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Impor Data (Restore)'),
                        ],
                      ),
                    ),
                  ],
                ),
              ]
            : null,
      ),
      body: activeBody,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: "Kategori",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: "Akun/Dompet",
          ),
        ],
      ),
    );
  }
}
