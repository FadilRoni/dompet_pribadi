import 'package:flutter/material.dart';
import '../data_model.dart';

class AkunScreen extends StatefulWidget {
  const AkunScreen({super.key});

  @override
  _AkunScreenState createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunScreen> {
  final TextEditingController _akunController = TextEditingController();

  void _editAkun(int index) {
    final String oldNama = masterAkun[index];
    final TextEditingController editController = TextEditingController(text: oldNama);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Akun/Dompet"),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(
              labelText: "Nama Akun/Dompet",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                if (editController.text.isNotEmpty) {
                  String newNama = editController.text;
                  setState(() {
                    masterAkun[index] = newNama;
                    // Update transaksi yang memakai akun ini
                    for (var t in daftarTransaksi) {
                      if (t.akun == oldNama) {
                        t.akun = newNama;
                      }
                    }
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
  }

  void _hapusAkun(int index) {
    if (masterAkun.length <= 1) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Tidak Dapat Menghapus"),
          content: Text("Minimal harus ada 1 akun/dompet."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    final String oldNama = masterAkun[index];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Hapus Akun/Dompet"),
          content: Text("Apakah Anda yakin ingin menghapus akun '$oldNama'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  masterAkun.removeAt(index);
                  // Update transaksi yang memakai akun ini ke akun pertama yang tersisa
                  for (var t in daftarTransaksi) {
                    if (t.akun == oldNama) {
                      t.akun = masterAkun.first;
                    }
                  }
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _akunController,
            decoration: InputDecoration(
              labelText: "Nama Akun/Dompet Baru (Misal: Mandiri)",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              if (_akunController.text.isNotEmpty) {
                setState(() {
                  masterAkun.add(_akunController.text);
                  saveData();
                  _akunController.clear();
                });
              }
            },
            child: Text("Simpan Akun"),
          ),
          Divider(height: 30),
          Expanded(
            child: ListView.builder(
              itemCount: masterAkun.length,
              itemBuilder: (c, i) {
                final akunNama = masterAkun[i];
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.account_balance_wallet, color: Colors.blue),
                    title: Text(akunNama),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () => _editAkun(i),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () => _hapusAkun(i),
                        ),
                      ],
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
