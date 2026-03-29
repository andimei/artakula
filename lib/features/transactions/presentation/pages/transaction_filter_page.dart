import 'package:flutter/material.dart';

class TransactionFilterPage extends StatelessWidget {
  const TransactionFilterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filter"),
      ),
      body: Column(
        children: [
          _sectionTitle("RENTANG WAKTU"),
          Wrap(
            spacing: 8,
            children: const [
              Chip(label: Text("Semua")),
              Chip(label: Text("Harian")),
              Chip(label: Text("Bulanan")),
              Chip(label: Text("Tahunan")),
              Chip(label: Text("Sesuaikan")),
            ],
          ),

          const SizedBox(height: 20),

          _sectionTitle("REKENING"),
          _fakeItem("bca"),
          _fakeItem("dompet"),
          _fakeItem("receh"),

          const SizedBox(height: 20),

          _sectionTitle("PENDAPATAN"),
          _fakeItem("Gaji"),
          _fakeItem("Hutang"),
          _fakeItem("Kiriman"),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text("FILTER"),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _fakeItem(String name) {
    return CheckboxListTile(
      value: true,
      onChanged: (_) {},
      title: Text(name),
    );
  }
}
