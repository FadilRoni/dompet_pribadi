import 'package:flutter/material.dart';

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

// DATA MASTER KATEGORI DALAM SATU GABUNGAN LIST
List<KategoriModel> masterKategori = [
  KategoriModel(nama: "Makanan", tipe: "Pengeluaran", ikon: Icons.fastfood),
  KategoriModel(
    nama: "Transportasi",
    tipe: "Pengeluaran",
    ikon: Icons.directions_car,
  ),
  KategoriModel(nama: "Gaji", tipe: "Pemasukan", ikon: Icons.payments),
  KategoriModel(nama: "Bonus", tipe: "Pemasukan", ikon: Icons.trending_up),
];

List<String> masterAkun = ["Tunai", "SeaBank", "SuperBank", "Krom Bank"];
List<Transaksi> daftarTransaksi = [];

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
