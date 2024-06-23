import 'package:flutter/material.dart';

class CalculusPage extends StatelessWidget {
  const CalculusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Aplikasi Pengenalan Penyakit Gigi',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: const [
              Text(
                'Pengertian Calculus',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Calculus atau karang gigi adalah suatu kondisi penumpukan plak dan bakteri pada gigi yang menyebabkan inflamasi dan kerusakan pada gusi. Calculus dapat menyebabkan sakit gigi, bau mulut, dan bahkan kehilangan gigi jika tidak ditangani.',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Text(
                'Cara Penanganan Calculus',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Berikut adalah beberapa cara penanganan calculus:',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.check),
                title: Text('Scaling'),
                subtitle: Text(
                    'Scaling adalah prosedur pembersihan plak dan tartar dari gigi untuk mencegah kerusakan gusi.'),
              ),
              ListTile(
                leading: Icon(Icons.check),
                title: Text('Root Planing'),
                subtitle: Text(
                    'Root planing adalah prosedur pembersihan akar gigi untuk menghilangkan plak dan tartar yang menempel.'),
              ),
              ListTile(
                leading: Icon(Icons.check),
                title: Text('Menggunakan antibiotik'),
                subtitle: Text(
                    'Antibiotik dapat membantu menghilangkan bakteri yang menyebabkan calculus.'),
              ),
              ListTile(
                leading: Icon(Icons.check),
                title: Text('Mengunjungi dokter gigi secara teratur'),
                subtitle: Text(
                    'Mengunjungi dokter gigi secara teratur dapat membantu mendeteksi calculus sejak dini dan melakukan penanganan yang tepat.'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}