import 'package:flutter/material.dart';
import '../data_model.dart';

class AkunScreen extends StatefulWidget {
  @override
  _AkunScreenState createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunScreen> {
  final TextEditingController _akunController = TextEditingController();

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
                itemBuilder: (c, i) => ListTile(
                  leading: Icon(
                    Icons.account_balance_wallet,
                    color: Colors.blue,
                  ),
                  title: Text(masterAkun[i]),
                ),
              ),
            ),
          ],
        ),
      );
  }
}
