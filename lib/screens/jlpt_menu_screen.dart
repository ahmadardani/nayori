import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/jlpt_model.dart';
import 'jlpt_quiz_screen.dart';

class JlptMenuScreen extends StatefulWidget {
  const JlptMenuScreen({super.key});

  @override
  State<JlptMenuScreen> createState() => _JlptMenuScreenState();
}

class _JlptMenuScreenState extends State<JlptMenuScreen> {
  bool _isLoading = true;
  List<JlptData> _jlptDataList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/jlpt/jlpt_data.json');
      final result = await compute(parseJlptDataInBackground, jsonString);
      setState(() {
        _jlptDataList = result;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading JLPT JSON: $e'); 
      setState(() => _isLoading = false);
    }
  }

  void _navigateToQuiz(JlptData paket, JlptSesi sesi) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => JlptQuizScreen(
          paket: paket,
          sesi: sesi,
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        title: const Text(
          'JLPT Mockup Test', 
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0, letterSpacing: -0.5)
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _jlptDataList.isEmpty 
              ? const Center(child: Text("Data belum tersedia."))
              : ListView.builder(
                  padding: EdgeInsets.only(
                    left: 20.0, 
                    right: 20.0, 
                    top: 16.0, 
                    bottom: MediaQuery.of(context).padding.bottom + 80.0, 
                  ),
                  itemCount: _jlptDataList.length,
                  itemBuilder: (context, index) {
                    final paket = _jlptDataList[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: borderColor, width: 1.0),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            title: Text(
                              'JLPT ${paket.level} - Tahun ${paket.tahun} (Bulan ${paket.bulan})', 
                              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, letterSpacing: -0.3)
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Icon(Icons.assignment_rounded, color: Theme.of(context).colorScheme.primary),
                            ),
                            children: paket.sesi.map((sesi) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(top: BorderSide(color: borderColor, width: 1.0))
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  title: Text(sesi.namaSesi, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('${sesi.mondaiList.length} Bagian Mondai'),
                                  trailing: const Icon(Icons.arrow_forward_rounded, color: Colors.grey),
                                  onTap: () => _navigateToQuiz(paket, sesi),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}