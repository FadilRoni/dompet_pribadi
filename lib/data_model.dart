import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';

class Transaksi {
  String id;
  double nominal;
  String catatan;
  String tipe;
  String kategori;
  String akun;
  DateTime tanggal;

  Transaksi({
    required this.id,
    required this.nominal,
    required this.catatan,
    required this.tipe,
    required this.kategori,
    required this.akun,
    required this.tanggal,
  });
}

// STRUKTUR BARU UNTUK KATEGORI
class KategoriModel {
  String nama;
  String tipe; // "Pengeluaran" atau "Pemasukan"
  IconData ikon; // Menyimpan logo ikon

  KategoriModel({required this.nama, required this.tipe, required this.ikon});
}

// DAFTAR PILIHAN LOGO/IKON YANG BISA DIPILIH USER
List<IconData> daftarPilihanIkon = [
  Icons.fastfood, // Makanan
  Icons.directions_car, // Transportasi
  Icons.shopping_bag, // Belanja
  Icons.receipt_long, // Tagihan
  Icons.payments, // Gaji
  Icons.card_giftcard, // Pemberian
  Icons.trending_up, // Investasi
  Icons.home, // Rumah
  Icons.bolt, // Listrik/Listrik
  Icons.medical_services, // Kesehatan
];

// DATA GLOBAL (akan diisi oleh database Hive saat aplikasi dimulai)
List<KategoriModel> masterKategori = [];
List<String> masterAkun = [];
List<Transaksi> daftarTransaksi = [];

// ================= HIVE DATABASE & EXPORT/IMPORT =================

// Serialisasi & Deserialisasi Transaksi
Map<String, dynamic> transaksiToMap(Transaksi t) {
  return {
    'id': t.id,
    'nominal': t.nominal,
    'catatan': t.catatan,
    'tipe': t.tipe,
    'kategori': t.kategori,
    'akun': t.akun,
    'tanggal': t.tanggal.toIso8601String(),
  };
}

Transaksi transaksiFromMap(Map<dynamic, dynamic> map) {
  return Transaksi(
    id: map['id'] ?? '',
    nominal: (map['nominal'] as num?)?.toDouble() ?? 0.0,
    catatan: map['catatan'] ?? '',
    tipe: map['tipe'] ?? '',
    kategori: map['kategori'] ?? '',
    akun: map['akun'] ?? '',
    tanggal: DateTime.tryParse(map['tanggal'] ?? '') ?? DateTime.now(),
  );
}

// Serialisasi & Deserialisasi Kategori
Map<String, dynamic> kategoriToMap(KategoriModel k) {
  return {
    'nama': k.nama,
    'tipe': k.tipe,
    'ikon': k.ikon.codePoint,
  };
}

KategoriModel kategoriFromMap(Map<dynamic, dynamic> map) {
  return KategoriModel(
    nama: map['nama'] ?? '',
    tipe: map['tipe'] ?? '',
    ikon: IconData(map['ikon'] ?? Icons.help.codePoint, fontFamily: 'MaterialIcons'),
  );
}

// Inisialisasi Database Hive
Future<void> initDatabase() async {
  await Hive.initFlutter();
  await Hive.openBox('dompet_pribadi_box');
  loadData();
}

// Menyimpan data ke Hive
void saveData() {
  final box = Hive.box('dompet_pribadi_box');
  
  final transaksiMaps = daftarTransaksi.map((t) => transaksiToMap(t)).toList();
  final kategoriMaps = masterKategori.map((k) => kategoriToMap(k)).toList();
  
  box.put('transaksi', transaksiMaps);
  box.put('kategori', kategoriMaps);
  box.put('akun', masterAkun);
}

// Memuat data dari Hive
void loadData() {
  final box = Hive.box('dompet_pribadi_box');
  
  // Load Akun (jika kosong, buat default)
  final List<dynamic>? savedAkun = box.get('akun');
  if (savedAkun != null) {
    masterAkun = List<String>.from(savedAkun);
  } else {
    masterAkun = ["Tunai", "SeaBank", "SuperBank", "Krom Bank"];
  }
  
  // Load Kategori (jika kosong, buat default)
  final List<dynamic>? savedKategori = box.get('kategori');
  if (savedKategori != null) {
    masterKategori = savedKategori.map((k) => kategoriFromMap(k as Map)).toList();
  } else {
    masterKategori = [
      KategoriModel(nama: "Makanan", tipe: "Pengeluaran", ikon: Icons.fastfood),
      KategoriModel(nama: "Transportasi", tipe: "Pengeluaran", ikon: Icons.directions_car),
      KategoriModel(nama: "Gaji", tipe: "Pemasukan", ikon: Icons.payments),
      KategoriModel(nama: "Bonus", tipe: "Pemasukan", ikon: Icons.trending_up),
    ];
  }
  
  // Load Transaksi
  final List<dynamic>? savedTransaksi = box.get('transaksi');
  if (savedTransaksi != null) {
    daftarTransaksi = savedTransaksi.map((t) => transaksiFromMap(t as Map)).toList();
  } else {
    daftarTransaksi = [];
  }
}

// Eksport data ke JSON
Future<void> exportData() async {
  try {
    final Map<String, dynamic> exportMap = {
      'transaksi': daftarTransaksi.map((t) => transaksiToMap(t)).toList(),
      'kategori': masterKategori.map((k) => kategoriToMap(k)).toList(),
      'akun': masterAkun,
    };
    
    final jsonString = jsonEncode(exportMap);
    
    // Simpan file sementara di direktori temp
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/dompet_pribadi_backup.json');
    await file.writeAsString(jsonString);
    
    // Share file tersebut
    await Share.shareXFiles([XFile(file.path)], text: 'Backup Data Catatan Keuangan');
  } catch (e) {
    print('Gagal mengekspor data: $e');
  }
}

// Import data dari JSON
Future<bool> importData() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> importMap = jsonDecode(jsonString);
      
      if (importMap.containsKey('transaksi') &&
          importMap.containsKey('kategori') &&
          importMap.containsKey('akun')) {
        
        final List<dynamic> importedAkun = importMap['akun'];
        final List<dynamic> importedKategori = importMap['kategori'];
        final List<dynamic> importedTransaksi = importMap['transaksi'];
        
        masterAkun = List<String>.from(importedAkun);
        masterKategori = importedKategori.map((k) => kategoriFromMap(k as Map)).toList();
        daftarTransaksi = importedTransaksi.map((t) => transaksiFromMap(t as Map)).toList();
        
        saveData();
        return true;
      }
    }
  } catch (e) {
    print('Gagal mengimpor data: $e');
  }
  return false;
}

// ================= FORMAT HELPER =================

String formatRibuan(double value) {
  bool isNegative = value < 0;
  double absValue = value.abs();

  // Split into integer and decimal parts
  String valueString = absValue.toString();
  List<String> parts = valueString.split('.');
  String integerPart = parts[0];
  String decimalPart = parts.length > 1 ? parts[1] : '';

  // Format integer part with dot as thousands separator
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  String formattedInteger = integerPart.replaceAllMapped(reg, (Match match) => '${match[1]}.');

  String result;
  if (decimalPart == '0' || decimalPart.isEmpty) {
    result = formattedInteger;
  } else {
    result = '$formattedInteger,$decimalPart';
  }

  return isNegative ? '-$result' : result;
}

class RibuanInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Ambil jumlah angka sebelum kursor pada input baru
    int cursorPosition = newValue.selection.end;
    String textBeforeCursor = newValue.text.substring(0, cursorPosition);
    int digitsBeforeCursor = textBeforeCursor.replaceAll(RegExp(r'[^\d]'), '').length;

    // Bersihkan semua non-digit
    String cleanText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    double value = double.parse(cleanText);
    String formatted = formatRibuan(value);

    // Cari posisi kursor baru berdasarkan jumlah digit yang ada sebelum kursor
    int newCursorPosition = 0;
    int digitCount = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (RegExp(r'\d').hasMatch(formatted[i])) {
        digitCount++;
      }
      newCursorPosition = i + 1;
      if (digitCount == digitsBeforeCursor) {
        break;
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }
}
