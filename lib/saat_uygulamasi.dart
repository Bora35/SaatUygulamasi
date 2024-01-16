import 'dart:async';
import 'package:flutter/material.dart';

class SaatUygulamasi extends StatefulWidget {
  const SaatUygulamasi({Key? key}) : super(key: key);

  @override
  _SaatUygulamasiState createState() => _SaatUygulamasiState();
}

class _SaatUygulamasiState extends State<SaatUygulamasi> {
  String _saatG =
      "${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}";
  Timer? _sayacTimer;

  final Stopwatch _kronometre = Stopwatch(); // Kronometre işlevini sağlamak için bir Stopwatch nesnesi oluşturulur
  final List<String> _kaydedilenSureler = [];
  final List<String> _kaydedilenSurelerTxt = [];

  String _saat = "0";
  String _dakika = "0";
  String _saniye = "0";
  int _kalanSure = 0;

  @override
  void initState() {
    super.initState();
    // Güncel saati güncellemek için bir zamanlayıcı başlatılır
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _saatG =
            "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')}";
      });
    });
  }
  // Kronometre sekmesindeki kodlar

  void _baslatDurdur() {
    setState(() {
      // Kronometre çalışıyorsa durdurulur, duruyorsa başlatılır
      if (_kronometre.isRunning) {
        _kronometre.stop();
        _sayacTimer?.cancel();
      } else {
        _kronometre.start();
        // Her 10 milisaniyede bir yeniden çizmek için bir zamanlayıcı başlatılır
        _sayacTimer = Timer.periodic(const Duration(milliseconds: 10), (_) {
          setState(() {});
        });
      }
    });
  }

  void _sifirlaKronometre() {
    setState(() {
      // Kronometre çalışıyorsa durdurulur ve sıfırlanır
      if (_kronometre.isRunning) {
        _kronometre.stop();
        _sayacTimer?.cancel();
      }
      _kronometre.reset();
      _kaydedilenSureler.clear();
      _kaydedilenSurelerTxt.clear();
    });
  }

  void _kaydet() {
    setState(() {
      if (_kronometre.isRunning) {
        Duration elapsedTime = _kronometre.elapsed;
        String formattedTime = _formatSure(elapsedTime);
        int kayitNo = _kaydedilenSureler.length + 1;

        String formattedDifference = formattedTime;
        if (_kaydedilenSureler.isNotEmpty) {
          Duration previousTime = _parseSure(_kaydedilenSureler.first);
          Duration timeDifference = elapsedTime - previousTime;
          formattedDifference = _formatSure(timeDifference);
        }

        String kayitMetni =
            '${kayitNo.toString().padLeft(2, '0').padRight(25)} +${formattedDifference.toString().padRight(25)} ${formattedTime.toString().padRight(25)}';

        _kaydedilenSureler.insert(0, formattedTime);
        _kaydedilenSurelerTxt.insert(0, kayitMetni);

        // Belirli bir kayıt sayısına ulaştığında durdurma işlemi
        const int maxKayitSayisi = 15;
        if (_kaydedilenSureler.length >= maxKayitSayisi) {
          _kronometre.stop();
          _sayacTimer?.cancel();
        }
      }
    });
  }

  Duration _parseSure(String sure) {
    List<String> parts = sure.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int seconds = int.parse(parts[2]);
    int milliseconds = parts.length > 3 ? int.parse(parts[3]) : 0;

    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
    );
  }

  void _baslatGerisayim() {
    int toplamSure = (int.tryParse(_saat) ?? 0) * 3600 +
        (int.tryParse(_dakika) ?? 0) * 60 +
        (int.tryParse(_saniye) ?? 0);

    setState(() {
      _kalanSure = toplamSure;
    });

    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (_kalanSure > 0) {
          _kalanSure--;
        } else {
          timer.cancel(); // Geri sayım durdur
          _kalanSureBildirim();
        }
      });
    });
  }

  void _kalanSureBildirim() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Süre Tamamlandı'),
          content: const Text('Zamanlayıcı süresi tamamlandı.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _formatSure(Duration duration) {
    String hours = (duration.inHours % 24).toString().padLeft(2, '0');
    String minutes =
        (duration.inMinutes.remainder(60)).toString().padLeft(2, '0');
    String seconds =
        (duration.inSeconds.remainder(60)).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  // State nesnesi yok edildiğinde çalışan bir metot. Zamanlayıcıyı iptal eder ve belleği temizler
  @override
  void dispose() {
    _sayacTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saat Uygulaması',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Saat Uygulaması'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.alarm), text: 'Alarm'),
                Tab(icon: Icon(Icons.access_time), text: 'Saat'),
                Tab(icon: Icon(Icons.timer_outlined), text: 'Zamanlayıcı'),
                Tab(icon: Icon(Icons.timer_off_outlined), text: 'Kronometre'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // Alarm sekmesi
              ListView(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.alarm),
                    title: const Text('Alarm 1'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        // Alarmı silme işlemi
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.alarm),
                    title: const Text('Alarm 2'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        // Alarmı silme işlemi
                      },
                    ),
                  ),
                  // ... diğer alarm listeleme işlemleri
                ],
              ),


              // Saat sekmesi
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      _saatG,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ],
                ),
              ),

              // Zamanlayıcı sekmesi
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        // kalan boşluğa yerleştirme
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Saat',
                            ),
                            onChanged: (value) {
                              setState(() {
                                _saat = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Dakika',
                            ),
                            onChanged: (value) {
                              setState(() {
                                _dakika = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Saniye',
                            ),
                            onChanged: (value) {
                              setState(() {
                                _saniye = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _baslatGerisayim();
                      },
                      child: const Text('Başlat'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Kalan Süre: ${_formatSure(Duration(seconds: _kalanSure))}',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              ),

              // Kronometre sekmesi
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    _formatSure(_kronometre.elapsed),
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: _baslatDurdur,
                        child: Text(
                          _kronometre.isRunning ? 'Durdur' : 'Başlat',
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _sifirlaKronometre,
                        child: const Text('Sıfırla'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _kaydet,
                        child: const Text('Kaydet'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _kaydedilenSurelerTxt.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          leading: const Icon(Icons.flag),
                          title: Text(
                            _kaydedilenSurelerTxt[index],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16, // Font büyüklüğünü ayarla
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),

          // // Alarm sekmesinde gösterilecek FloatingActionButton
          // floatingActionButton: DefaultTabController.of(context).index == 0
          //     ? FloatingActionButton(
          //   onPressed: () {
          //     // Yeni alarm ekleme işlemleri burada gerçekleştirilir
          //   },
          //   child: const Icon(Icons.add),
          // )
          //     : null,
          //
        ),
      ),
    );
  }
}
