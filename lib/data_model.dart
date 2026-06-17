class Transaksi {
  String id;
  double nominal;
  String catatan;
  String tipe; // "Pengeluaran" atau "Pemasukan"
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

// SEKARANG DIPISAH MENJADI DUA LIST
List<String> kategoriPengeluaran = [
  "Makanan",
  "Minum",
  "Transportasi",
  "Belanja",
  "Tagihan",
];

List<String> kategoriPemasukan = ["Gaji", "Bonus", "Investasi", "Pemberian"];

List<String> masterAkun = ["Tunai", "SeaBank", "SuperBank", "Krom Bank"];
List<Transaksi> daftarTransaksi = [];
