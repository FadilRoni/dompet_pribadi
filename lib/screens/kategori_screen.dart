import 'package:flutter/material.dart';
import '../data_model.dart';

class KategoriScreen extends StatefulWidget {
  @override
  _KategoriScreenState createState() => _KategoriScreenState();
}

class _KategoriScreenState extends State<KategoriScreen> {
  final TextEditingController _kategoriController = TextEditingController();
  String _tipeKategoriBaru = "Pengeluaran";
  IconData _ikonTerpilih = daftarPilihanIkon.first; // Default logo pertama

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. INPUT NAMA KATEGORI
            TextField(
              controller: _kategoriController,
              decoration: InputDecoration(
                labelText: "Nama Kategori Baru",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            // 2. PILIHAN TIPE (PENGELUARAN / PEMASUKAN)
            Row(
              children: [
                Text(
                  "Tipe Kategori: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: _tipeKategoriBaru,
                  items: ["Pengeluaran", "Pemasukan"].map((String val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Text(val),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _tipeKategoriBaru = val!),
                ),
              ],
            ),
            SizedBox(height: 10),

            // 3. PILIHAN LOGO / IKON (Bentuk Grid Horisontal)
            Text(
              "Pilih Logo Kategori:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Container(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: daftarPilihanIkon.length,
                itemBuilder: (context, index) {
                  IconData ikon = daftarPilihanIkon[index];
                  bool isSelected = _ikonTerpilih == ikon;
                  return GestureDetector(
                    onTap: () => setState(() => _ikonTerpilih = ikon),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green : Colors.grey.shade800,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(ikon, color: Colors.white),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 15),

            // 4. TOMBOL SIMPAN
            ElevatedButton(
              onPressed: () {
                if (_kategoriController.text.isNotEmpty) {
                  setState(() {
                    masterKategori.add(
                      KategoriModel(
                        nama: _kategoriController.text,
                        tipe: _tipeKategoriBaru,
                        ikon: _ikonTerpilih,
                      ),
                    );
                    saveData();
                    _kategoriController.clear();
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text("Simpan Kategori"),
            ),
            Divider(height: 30, color: Colors.grey),

            // 5. DAFTAR SEMUA KATEGORI DALAM SATU LIST
            Text(
              "Daftar Kategori Saat Ini:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: masterKategori.length,
                itemBuilder: (context, index) {
                  final item = masterKategori[index];
                  bool isPengeluaran = item.tipe == "Pengeluaran";

                  return Card(
                    child: ListTile(
                      // Menampilkan Logo Ikon yang dipilih
                      leading: CircleAvatar(
                        backgroundColor: isPengeluaran
                            ? Colors.red.shade900
                            : Colors.green.shade900,
                        child: Icon(item.ikon, color: Colors.white),
                      ),
                      title: Text(item.nama),
                      // Label Pembeda Tipe di sebelah kanan
                      trailing: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isPengeluaran
                              ? Colors.red.withOpacity(0.2)
                              : Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          item.tipe,
                          style: TextStyle(
                            color: isPengeluaran
                                ? Colors.redAccent
                                : Colors.greenAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
  }
}
