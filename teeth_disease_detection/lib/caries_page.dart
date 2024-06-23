import 'package:flutter/material.dart';

class CariesPage extends StatelessWidget {
  const CariesPage({super.key});

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
                'Pengertian Caries',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Caries adalah suatu kondisi kerusakan pada gigi yang disebabkan oleh bakteri dan asam yang dihasilkan oleh bakteri tersebut. Caries dapat menyebabkan lubang pada gigi dan jika tidak ditangani dapat menyebabkan sakit gigi dan bahkan kehilangan gigi.',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Text(
                'Cara Penanganan Caries',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Berikut adalah beberapa cara penanganan caries:',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.check),
                title: Text('Menggosok gigi secara teratur'),
                subtitle: Text(
                    'Menggosok gigi secara teratur dapat membantu menghilangkan bakteri dan asam yang menyebabkan caries.'),
              ),
              ListTile(
                leading: Icon(Icons.check),
                title: Text('Menggunakan fluoride'),
                subtitle: Text(
                    'Fluoride dapat membantu menguatkan gigi dan mencegah caries.'),
              ),
              ListTile(
                leading: Icon(Icons.check),
                title: Text('Mengkonsumsi makanan yang seimbang'),
                subtitle: Text(
                    'Mengkonsumsi makanan yang seimbang dapat membantu menjaga kesehatan gigi dan mencegah caries.'),
              ),
              ListTile(
                leading: Icon(Icons.check),
                title: Text('Mengunjungi dokter gigi secara teratur'),
                subtitle: Text(
                    'Mengunjungi dokter gigi secara teratur dapat membantu mendeteksi caries sejak dini dan melakukan penanganan yang tepat.'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
