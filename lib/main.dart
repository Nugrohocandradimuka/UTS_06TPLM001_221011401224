import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import untuk inisialisasi data lokal
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

void main() async { // Tambahkan async karena initializeDateFormatting adalah Future
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan binding Flutter sudah diinisialisasi
  await initializeDateFormatting('id_ID', null).then((_) => runApp(const CandraWeatherApp()));
}

class CandraWeatherApp extends StatelessWidget {
  const CandraWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'nugroho candra dimuka',
      home: const WeatherHome(),
    );
  }
}

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  String cityName = '...';
  String description = '';
  double temp = 0;
  double tempMin = 0;
  double tempMax = 0;
  String icon = '';
  bool isLoading = true;

  final String apiKey = 'cc1d1bf9392226fcb259e175e91d7f5a';

  @override
  void initState() {
    super.initState();
    getLocationAndWeather();
  }

  Future<void> getLocationAndWeather() async {
    try {
      // Minta izin lokasi
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() {
          description = 'Izin lokasi ditolak';
          isLoading = false;
        });
        return;
      }

      // Ambil lokasi pengguna
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Ambil nama kota
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        cityName = placemarks[0].locality ?? 'Lokasi Tidak Dikenal';
      }

      // Panggil API cuaca
      final url =
          'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric&lang=id';
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      setState(() {
        description = data['weather'][0]['description'];
        icon = data['weather'][0]['icon'];
        temp = data['main']['temp'];
        tempMin = data['main']['temp_min'];
        tempMax = data['main']['temp_max'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        description = 'Gagal mengambil data';
        isLoading = false;
      });
    }
  }

  String getFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, dd MMMM yyyy', 'id_ID'); // Tambahkan tahun agar lebih lengkap
    return formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    final dateText = getFormattedDate();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF88BBD6), Color(0xFF1E3C72)],
          ),
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cityName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dateText,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Image.network(
                      'https://openweathermap.org/img/wn/$icon@2x.png',
                      width: 100,
                      height: 100,
                    ),
                    Text(
                      '${temp.toStringAsFixed(0)}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(width: 150, height: 1, color: Colors.white54),
                    const SizedBox(height: 20),
                    Text(
                      description[0].toUpperCase() + description.substring(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${tempMin.toStringAsFixed(0)}°C / ${tempMax.toStringAsFixed(0)}°C',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}