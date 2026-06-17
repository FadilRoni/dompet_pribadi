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

  // Filter Tanggal Default: Bulan Juni 2026 (Menyesuaikan waktu saat ini)
  DateTime rangeMulai = DateTime(2026, 6, 1);
  DateTime rangeSelesai = DateTime(2026, 6, 30);

  @override
  Widget build(BuildContext context) {
    // Memilih kategori yang sesuai secara dinamis
    List<String> kategoriAktif = _pilihanTipe == "Pengeluaran"
        ? kategoriPengeluaran
        : kategoriPemasukan;

    // Proteksi error jika list kosong atau data berubah
    if (kategoriAktif.isNotEmpty && !kategoriAktif.contains(_pilihanKategori)) {
      _pilihanKategori = kategoriAktif.first;
    }

    // Filter data berdasarkan Range Tanggal & Hitung Saldo Bersih
    double totalSaldo = 0;
    List<Transaksi> riwayatTerfilter = daftarTransaksi.where((t) {
      bool masukRange =
          t.tanggal.isAfter(rangeMulai.subtract(Duration(days: 1))) &&
          t.tanggal.isBefore(rangeSelesai.add(Duration(days: 1)));
      if (masukRange) {
        if (t.tipe == "Pemasukan") totalSaldo += t.nominal;
        if (t.tipe == "Pengeluaran") totalSaldo -= t.nominal;
      }
      return masukRange;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text("Keuanganku (Offline)")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TOMBOL NAVIGASI KE HALAMAN LAIN
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (c) => KategoriScreen()),
                    ).then((_) => setState(() {})),
                    child: Text("Kategori"),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (c) => AkunScreen()),
                    ).then((_) => setState(() {})),
                    child: Text("Akun/Dompet"),
                  ),
                ),
              ],
            ),
            Card(
              margin: EdgeInsets.symmetric(vertical: 15),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "FORM INPUT TRANSAKSI",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _nominalController,
                      keyboardType: TextInputType.number,
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
                                    double.tryParse(_nominalController.text) ??
                                    0,
                                catatan: _catatanController.text,
                                tipe: _pilihanTipe,
                                kategori: _pilihanKategori,
                                akun: _pilihanAkun,
                                tanggal: DateTime.now(),
                              ),
                            );
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
            // RINGKASAN SALDO
            Container(
              padding: EdgeInsets.all(12),
              // Ubah baris color di bawah ini agar warnanya transparan/menyesuaikan tema gelap:
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.blueGrey.shade900
                  : Colors.blue.shade50,
              child: Text(
                "Total Saldo Periode Ini: Rp $totalSaldo",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: totalSaldo >= 0
                      ? Colors.greenAccent
                      : Colors
                            .redAccent, // Menggunakan warna Accent agar lebih menyala di layar gelap
                ),
                textAlign: TextAlign.center,
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
                  trailing: Text(
                    "${item.tipe == "Pengeluaran" ? "-" : "+"} Rp ${item.nominal}",
                    style: TextStyle(
                      color: item.tipe == "Pengeluaran"
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
