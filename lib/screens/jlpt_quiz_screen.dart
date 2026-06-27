import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../models/jlpt_model.dart';

class JlptQuizItem {
  final JlptMondai mondai;
  final JlptSoal soal;
  JlptQuizItem(this.mondai, this.soal);
}

class JlptQuizScreen extends StatefulWidget {
  final JlptData paket;
  final JlptSesi sesi;

  const JlptQuizScreen({super.key, required this.paket, required this.sesi});

  @override
  State<JlptQuizScreen> createState() => _JlptQuizScreenState();
}

class _JlptQuizScreenState extends State<JlptQuizScreen> {
  List<JlptQuizItem> _activeQueue = [];
  List<JlptQuizItem> _incorrectQueue = [];
  
  int _currentIndex = 0;
  bool _isAnswered = false;
  bool _isCorrect = false;
  int? _selectedAnswerIndex;

  int _totalCorrect = 0;
  int _totalWrong = 0;
  bool _isQuizFinished = false;
  
  bool _showInformation = false;
  bool _showTranslationBacaan = false;
  bool _showTranslationSoal = false;

  @override
  void initState() {
    super.initState();
    _generateQuestions();
  }

  void _generateQuestions() {
    List<JlptQuizItem> items = [];
    for (var mondai in widget.sesi.mondaiList) {
      for (var soal in mondai.soalList) {
        if (!soal.isContoh) {
          items.add(JlptQuizItem(mondai, soal));
        }
      }
    }
    _activeQueue = List.from(items);
  }

  void _checkAnswer() {
    if (_selectedAnswerIndex == null) return;

    final currentQ = _activeQueue[_currentIndex];

    setState(() {
      _isAnswered = true; 
      if (_selectedAnswerIndex == currentQ.soal.jawabanBenar) {
        _isCorrect = true;
        _totalCorrect++;
      } else {
        _isCorrect = false;
        _totalWrong++;
        if (!_incorrectQueue.contains(currentQ)) {
          _incorrectQueue.add(currentQ);
        }
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _isAnswered = false; 
      _isCorrect = false;
      _selectedAnswerIndex = null;
      _showInformation = false; 
      _showTranslationBacaan = false;
      _showTranslationSoal = false;

      if (_currentIndex < _activeQueue.length - 1) {
        _currentIndex++;
      } else {
        _isQuizFinished = true;
      }
    });
  }

  void _retryIncorrect() {
    setState(() {
      _activeQueue = List.from(_incorrectQueue);
      _incorrectQueue.clear();
      _currentIndex = 0;
      _totalCorrect = 0;
      _totalWrong = 0;
      _isQuizFinished = false;
      _isAnswered = false;
      _selectedAnswerIndex = null;
      _showInformation = false; 
      _showTranslationBacaan = false;
      _showTranslationSoal = false;
    });
  }

  void _showPembahasanBottomSheet(JlptSoal soal) {
    if (soal.pembahasan == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return ListView(
              controller: controller,
              padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(context).padding.bottom + 48,),
              children: [
                Row(
                  children: [
                    Icon(Icons.menu_book_rounded, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8.0),
                    const Text('Pembahasan', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(height: 32),
                
                // Detail Pilihan
                if (soal.pembahasan!.detailPilihan.isNotEmpty) ...[
                  const Text('Pilihan Jawaban:', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  ...soal.pembahasan!.detailPilihan.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14.0, height: 1.5),
                        children: [
                          TextSpan(text: '${p.teks}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: p.arti),
                          if (p.penjelasan != null) TextSpan(text: ' - ${p.penjelasan}', style: const TextStyle(fontStyle: FontStyle.italic)),
                          TextSpan(
                            text: p.isBenar ? ' (Benar)' : ' (Salah)',
                            style: TextStyle(color: p.isBenar ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 16.0),
                ],

                // Kosa Kata
                if (soal.pembahasan!.kosaKata.isNotEmpty) ...[
                  const Text('Kosa Kata:', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  ...soal.pembahasan!.kosaKata.map((k) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text('• ${k.kanji} (${k.hiragana}): ${k.arti}', style: const TextStyle(fontSize: 14.0)),
                  )),
                  const SizedBox(height: 16.0),
                ],

                // Grammar
                if (soal.pembahasan!.grammar.isNotEmpty) ...[
                  const Text('Tata Bahasa:', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  ...soal.pembahasan!.grammar.map((g) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ${g.pola}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
                        Text(g.penjelasan, style: const TextStyle(fontSize: 14.0)),
                        if (g.contoh.isNotEmpty) ...g.contoh.map((c) => Text('  Contoh: $c', style: const TextStyle(fontSize: 13.0, fontStyle: FontStyle.italic, color: Colors.grey))),
                      ],
                    ),
                  )),
                ],
              ],
            );
          }
        );
      },
    );
  }


  Future<bool> _onWillPop() async {
    if (_isQuizFinished) return true;
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        title: const Text('Exit Practice?'),
        content: const Text('You have not finished this test. Are you sure you want to leave?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Leave')),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  void _showContohBottomSheet(JlptSoal contohSoal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8.0),
                    const Text('Contoh Soal (例)', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(height: 32),
                MarkdownBody(
                  data: contohSoal.pertanyaan,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, height: 1.5),
                  ),
                ),
                const SizedBox(height: 24.0),
                ...List.generate(contohSoal.pilihan.length, (idx) {
                  final isCorrectAnswer = idx == contohSoal.jawabanBenar;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: isCorrectAnswer ? Colors.green.withOpacity(0.15) : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: isCorrectAnswer ? Colors.green : Colors.grey.withOpacity(0.3),
                        width: isCorrectAnswer ? 2.0 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text('${idx + 1}. ', style: TextStyle(fontWeight: FontWeight.bold, color: isCorrectAnswer ? Colors.green.shade700 : Colors.grey)),
                        Expanded(
                          child: Text(
                            contohSoal.pilihan[idx],
                            style: TextStyle(fontSize: 16.0, fontWeight: isCorrectAnswer ? FontWeight.bold : FontWeight.normal),
                          ),
                        ),
                        if (isCorrectAnswer)
                          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20.0),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) Navigator.pop(context, true);
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: bgColor,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          title: Text(
            widget.sesi.idSesi == 'moji_goi' ? 'Moji/Goi' : 'Bunpou/Dokkai', 
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w800, letterSpacing: -0.5)
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: LinearProgressIndicator(
              value: _isQuizFinished || _activeQueue.isEmpty ? 1.0 : (_currentIndex + 1) / _activeQueue.length,
              backgroundColor: Colors.grey.withOpacity(0.2),
            ),
          ),
        ),
        body: _isQuizFinished 
            ? _buildResultScreen() 
            : _activeQueue.isEmpty 
                ? const Center(child: Text("Tidak ada soal tersedia."))
                : Column(
                    children: [
                      Expanded(child: _buildQuizContent(borderColor)),
                      _buildBottomActionPanel(borderColor),
                    ],
                  ),
      ),
    );
  }

  Widget _buildQuizContent(Color borderColor) {
    final currentQ = _activeQueue[_currentIndex];
    
    final soalContohList = currentQ.mondai.soalList.where((s) => s.isContoh).toList();
    final bool hasContoh = soalContohList.isNotEmpty;
    final bool hasTeksBacaan = currentQ.mondai.teksBacaan != null && currentQ.mondai.teksBacaan!.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              'Mondai ${currentQ.mondai.nomorMondai}  •  Soal ${_currentIndex + 1} of ${_activeQueue.length}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14.0, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 24.0),
          
          Container(
            padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 8.0, bottom: 8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    currentQ.mondai.instruksi,
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14.0),
                  ),
                ),
                if (hasContoh)
                  IconButton(
                    icon: Icon(Icons.help_outline_rounded, color: Theme.of(context).colorScheme.primary),
                    tooltip: 'Lihat Contoh (Rei)',
                    onPressed: () => _showContohBottomSheet(soalContohList.first),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),

          if (hasTeksBacaan) ...[
            InkWell(
              onTap: () => setState(() => _showInformation = !_showInformation),
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _showInformation ? 'Sembunyikan Teks Bacaan' : 'Tampilkan Teks Bacaan',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      _showInformation ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: !_showInformation
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: borderColor),
                          ),
                          child: Text(currentQ.mondai.teksBacaan!, style: const TextStyle(fontSize: 15.0, height: 1.6)),
                        ),
                        if (currentQ.mondai.terjemahanBacaan != null && currentQ.mondai.terjemahanBacaan!.isNotEmpty) ...[
                          const SizedBox(height: 4.0),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => setState(() => _showTranslationBacaan = !_showTranslationBacaan),
                              icon: Icon(_showTranslationBacaan ? Icons.translate_rounded : Icons.language_rounded, size: 14.0),
                              label: Text(_showTranslationBacaan ? 'Sembunyikan Terjemahan' : 'Lihat Terjemahan'),
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context).colorScheme.primary,
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(50, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: !_showTranslationBacaan
                                ? const SizedBox.shrink()
                                : Container(
                                    margin: const EdgeInsets.only(top: 4.0),
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Terjemahan:', style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: Colors.blue)),
                                        const SizedBox(height: 8.0),
                                        Text(
                                          currentQ.mondai.terjemahanBacaan!,
                                          style: const TextStyle(fontSize: 14.0, height: 1.5, fontStyle: FontStyle.italic),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ],
                        const SizedBox(height: 24.0),
                      ],
                    ),
            ),
          ],

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: MarkdownBody(
                  data: currentQ.soal.pertanyaan,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, height: 1.5),
                    strong: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.content_copy_rounded, size: 20.0),
                onPressed: () {
                  final buffer = StringBuffer();
                  buffer.writeln(currentQ.soal.pertanyaan.replaceAll('**', ''));
                  for (int i = 0; i < currentQ.soal.pilihan.length; i++) {
                    buffer.writeln('${i + 1}. ${currentQ.soal.pilihan[i]}');
                  }
                  Clipboard.setData(ClipboardData(text: buffer.toString()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Soal dan pilihan berhasil disalin'), duration: Duration(seconds: 1)),
                  );
                },
              ),
            ],
          ),
          
          if (currentQ.soal.terjemahanSoal != null && currentQ.soal.terjemahanSoal!.isNotEmpty) ...[
            const SizedBox(height: 4.0),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => _showTranslationSoal = !_showTranslationSoal),
                icon: Icon(_showTranslationSoal ? Icons.translate_rounded : Icons.language_rounded, size: 14.0),
                label: Text(_showTranslationSoal ? 'Sembunyikan Arti' : 'Arti Pertanyaan'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.outline,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 20),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: !_showTranslationSoal
                  ? const SizedBox.shrink()
                  : Container(
                      margin: const EdgeInsets.only(top: 8.0),
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: borderColor.withOpacity(0.5)),
                      ),
                      child: Text(
                        currentQ.soal.terjemahanSoal!,
                        style: TextStyle(fontSize: 14.0, height: 1.4, color: Theme.of(context).colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic),
                      ),
                    ),
            ),
          ],
          const SizedBox(height: 32.0),

          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(currentQ.soal.pilihan.length, (index) {
              final isSelected = _selectedAnswerIndex == index;
              
              Color? btnBgColor;
              Color? btnBorderColor;
              Color? textColor = Theme.of(context).colorScheme.onSurface;

              if (_isAnswered) {
                if (index == currentQ.soal.jawabanBenar) {
                  btnBgColor = Colors.green.withOpacity(0.15);
                  btnBorderColor = Colors.green;
                  textColor = Colors.green.shade700;
                } else if (isSelected && index != currentQ.soal.jawabanBenar) {
                  btnBgColor = Colors.red.withOpacity(0.15);
                  btnBorderColor = Colors.red;
                  textColor = Colors.red.shade700;
                } else {
                  btnBgColor = Theme.of(context).colorScheme.surface;
                  btnBorderColor = borderColor;
                }
              } else {
                btnBgColor = isSelected ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surface;
                btnBorderColor = isSelected ? Theme.of(context).colorScheme.primary : borderColor;
                if (isSelected) textColor = Theme.of(context).colorScheme.primary;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: _isAnswered ? null : () => setState(() => _selectedAnswerIndex = index),
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    decoration: BoxDecoration(
                      color: btnBgColor,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: btnBorderColor, width: isSelected || (_isAnswered && index == currentQ.soal.jawabanBenar) ? 2.0 : 1.0),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${index + 1}. ',
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: textColor.withOpacity(0.7)),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            currentQ.soal.pilihan[index],
                            style: TextStyle(fontSize: 18.0, fontWeight: isSelected || _isAnswered ? FontWeight.bold : FontWeight.w500, color: textColor),
                          ),
                        ),
                        if (_isAnswered && index == currentQ.soal.jawabanBenar)
                          const Icon(Icons.check_circle_rounded, color: Colors.green)
                        else if (_isAnswered && isSelected && index != currentQ.soal.jawabanBenar)
                          const Icon(Icons.cancel_rounded, color: Colors.red),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionPanel(Color borderTopColor) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!_isAnswered) {
      return SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(top: BorderSide(color: borderTopColor, width: 1.0)),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50.0,
            child: ElevatedButton(
              onPressed: _selectedAnswerIndex == null ? null : _checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                elevation: 0.0,
              ),
              child: const Text('Check Answer', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      );
    }

    final isLast = _currentIndex >= _activeQueue.length - 1;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final panelColor = _isCorrect ? Colors.green.shade100 : Colors.red.shade100;
    final textColor = _isCorrect ? Colors.green.shade800 : Colors.red.shade800;
    final iconData = _isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded;

    final finalPanelColor = isDark ? (_isCorrect ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15)) : panelColor;
    final finalTextColor = isDark ? (_isCorrect ? Colors.green.shade400 : Colors.red.shade400) : textColor;
    
    final currentQ = _activeQueue[_currentIndex]; // Ambil data soal saat ini

    return Container(
      color: finalPanelColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(iconData, color: finalTextColor, size: 28.0),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      _isCorrect ? 'Excellent!' : 'Incorrect',
                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: finalTextColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              
              // Perubahan: Menggunakan Row untuk membagi 2 tombol
              Row(
                children: [
                  if (currentQ.soal.pembahasan != null) ...[
                    Expanded(
                      child: SizedBox(
                        height: 50.0,
                        child: OutlinedButton(
                          onPressed: () => _showPembahasanBottomSheet(currentQ.soal),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: finalTextColor,
                            side: BorderSide(color: finalTextColor, width: 2.0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),
                          child: const Icon(Icons.auto_stories_rounded, size: 24, ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                  ],
                  Expanded(
                    flex: 2, // Tombol continue dibuat sedikit lebih lebar
                    child: SizedBox(
                      height: 50.0,
                      child: ElevatedButton(
                        onPressed: _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isCorrect ? Colors.green : Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                          elevation: 0.0,
                        ),
                        child: Text(
                          isLast ? 'Finish Practice' : 'Continue', 
                          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    bool isPerfect = _incorrectQueue.isEmpty;

    return Padding(
      padding: EdgeInsets.only(
        left: 24.0, right: 24.0, top: 24.0, 
        bottom: MediaQuery.of(context).padding.bottom + 48.0
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            isPerfect ? Icons.workspace_premium_rounded : Icons.edit_note_rounded,
            size: 90.0,
            color: isPerfect ? Colors.amber.shade500 : Colors.blueGrey.shade400,
          ),
          const SizedBox(height: 24.0),
          Text(
            isPerfect ? 'Perfect! Stage Cleared!' : 'Keep Practicing!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28.0, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
          const SizedBox(height: 40.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn('Correct', _totalCorrect, Colors.green.shade600),
              _buildStatColumn('Incorrect', _totalWrong, Colors.red.shade600),
            ],
          ),
          const Spacer(),
          if (!isPerfect)
            ElevatedButton.icon(
              onPressed: _retryIncorrect,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry Incorrect', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Colors.orange.shade700, 
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                elevation: 2.0, 
              ),
            ),
          const SizedBox(height: 16.0),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context, true); 
            },
            icon: const Icon(Icons.home_rounded),
            label: const Text('Back to Menu', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant, 
              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              elevation: 0.0,
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, int value, Color color) {
    return Column(
      children: [
        Text(value.toString(), style: TextStyle(fontSize: 36.0, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 4.0),
        Text(label, style: const TextStyle(fontSize: 14.0, color: Colors.grey, fontWeight: FontWeight.w600)),
      ],
    );
  }
}