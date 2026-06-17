import 'package:flutter/material.dart';
import '../data_model.dart';

class KategoriScreen extends StatefulWidget {
  @override
  _KategoriScreenState createState() => _KategoriScreenState();
}

class _KategoriScreenState extends State<KategoriScreen> {
  final TextEditingController _kategoriController = TextEditingController();
  String _tipeKategoriBaru = "Pengeluaran";

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Master Kategori"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Pengeluaran"),
              Tab(text: "Pemasukan"),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _kategoriController,
                decoration: InputDecoration(
                  labelText: "Nama Kategori Baru",
                  border: OutlineInputBorder(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Tipe: "),
                  DropdownButton<String>(
                    value: _tipeKategoriBaru,
                    items: ["Pengeluaran", "Pemasukan"].map((String val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(val),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => _tipeKategoriBaru = val!),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  if (_kategoriController.text.isNotEmpty) {
                    setState(() {
                      if (_tipeKategoriBaru == "Pengeluaran") {
                        kategoriPengeluaran.add(_kategoriController.text);
                      } else {
                        kategoriPemasukan.add(_kategoriController.text);
                      }
                      _kategoriController.clear();
                    });
                  }
                },
                child: Text("Simpan Kategori"),
              ),
              Divider(height: 30),
              Expanded(
                child: TabBarView(
                  children: [
                    ListView.builder(
                      itemCount: kategoriPengeluaran.length,
                      itemBuilder: (c, i) => ListTile(
                        leading: Icon(Icons.arrow_downward, color: Colors.red),
                        title: Text(kategoriPengeluaran[i]),
                      ),
                    ),
                    ListView.builder(
                      itemCount: kategoriPemasukan.length,
                      itemBuilder: (c, i) => ListTile(
                        leading: Icon(Icons.arrow_upward, color: Colors.green),
                        title: Text(kategoriPemasukan[i]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
