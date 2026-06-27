import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import '../models/jt_pair_model.dart';

class VerbPairQuizScreen extends StatefulWidget {
  final String level;

  const VerbPairQuizScreen({super.key, required this.level});

  @override
  State<VerbPairQuizScreen> createState() => _VerbPairQuizScreenState();
}

class _VerbPairQuizScreenState extends State<VerbPairQuizScreen> {
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FlutterTts flutterTts = FlutterTts(); 
  
  List<JTPair> _activeQueue = [];
  List<JTPair> _incorrectQueue = [];
  
  bool _isLoading = true;
  bool _isStarting = true; 
  bool _autoPlayAudio = true; 
  
  int _currentIndex = 0;
  bool _showHint = false;
  bool _isAnswered = false;
  bool _isCorrect = false;

  int _totalCorrect = 0;
  int _totalWrong = 0;
  bool _isQuizFinished = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadAndPrepareData();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("ja-JP");
    await flutterTts.setSpeechRate(0.45); 
  }

  Future<void> _speak(String text) async {
    String cleanText = text.replaceAll(RegExp(r'\s*\(.*?\)'), '').trim();
    await flutterTts.speak(cleanText);
  }

  Future<void> _loadAndPrepareData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/jidoushi_tadoushi_verbs.json');
      final List<dynamic> parsedJson = json.decode(jsonString);
      final List<JTPair> allPairs = parsedJson.map((json) => JTPair.fromJson(json)).toList();

      List<JTPair> levelPairs = allPairs.where((p) => p.level == widget.level).toList();

      levelPairs.sort((a, b) {
        int numCompare = a.number.compareTo(b.number);
        if (numCompare != 0) return numCompare;
        
        if (a.type == '自動詞' && b.type != '自動詞') return -1;
        if (a.type != '自動詞' && b.type == '自動詞') return 1;
        return 0;
      });

      setState(() {
        _activeQueue = levelPairs;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading pairs json: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    _focusNode.dispose();
    flutterTts.stop(); 
    super.dispose();
  }

  void _handleSubmitted(String text) {
    if (!_isAnswered) {
      _checkAnswer();
    } else if (_isAnswered && !_isCorrect) {
      _checkAnswer(); 
    } else {
      _nextQuestion();
    }
  }

  void _checkAnswer() {
    if (_answerController.text.trim().isEmpty) return;

    FocusScope.of(context).unfocus(); 
    final currentQ = _activeQueue[_currentIndex];
    
    String normalizeText(String text) {
      String normalized = text.replaceAll(' ', '').replaceAll('　', '').replaceAll('。', '').toLowerCase();
      const fullWidth = 'ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ１２３４５６７８９０？！';
      const halfWidth = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890?!';
      for (int i = 0; i < fullWidth.length; i++) {
        normalized = normalized.replaceAll(fullWidth[i], halfWidth[i].toLowerCase());
      }
      return normalized;
    }

    final userAnswer = normalizeText(_answerController.text);
    String cleanJapanese = currentQ.japanese.replaceAll(RegExp(r'\s*\(.*?\)'), '').trim();
    final correctAnswer = normalizeText(cleanJapanese); 

    bool isTextMatch = (userAnswer == correctAnswer);

    if (!_isAnswered) {
      setState(() {
        _isAnswered = true; 
        if (isTextMatch) {
          _isCorrect = true;
          _totalCorrect++;
        } else {
          _isCorrect = false;
          _totalWrong++;
          if (!_incorrectQueue.contains(currentQ)) {
            _incorrectQueue.add(currentQ);
          }
          _answerController.clear(); 
        }
      });

      if (!isTextMatch) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _focusNode.requestFocus();
        });
      }
      
      if (_autoPlayAudio) {
        _speak(currentQ.japanese); 
      }
      
    } else {
      if (isTextMatch) {
        _nextQuestion(); 
      } else {
        setState(() => _answerController.clear());
      }
    }
  }

  void _nextQuestion() {
    setState(() {
      _answerController.clear();
      _showHint = false;
      _isAnswered = false; 
      _isCorrect = false;

      if (_currentIndex < _activeQueue.length - 1) {
        _currentIndex++;
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) _focusNode.requestFocus();
        });
      } else {
        _isQuizFinished = true;
        FocusScope.of(context).unfocus(); 
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
      _focusNode.requestFocus(); 
    });
  }

  Future<bool> _onWillPop() async {
    if (_isStarting || _isQuizFinished) return true;
    
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        title: const Text('Exit Practice?'),
        content: const Text('You have not finished this practice. Are you sure you want to leave?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Leave')),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
          title: Text(
            '${widget.level} Pairs Practice', 
            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w800, letterSpacing: -0.5)
          ),
          centerTitle: true,
          bottom: _isStarting 
            ? null 
            : PreferredSize(
                preferredSize: const Size.fromHeight(4.0),
                child: LinearProgressIndicator(
                  value: _isQuizFinished || _activeQueue.isEmpty ? 1.0 : (_currentIndex + 1) / _activeQueue.length,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                ),
              ),
          actions: _isStarting ? null : [
            IconButton(
              icon: Icon(_autoPlayAudio ? Icons.volume_up_rounded : Icons.volume_off_rounded),
              tooltip: 'Toggle Auto-play Audio',
              onPressed: () => setState(() => _autoPlayAudio = !_autoPlayAudio),
            ),
          ],
        ),
        body: _isStarting
            ? _buildStartScreen(borderColor)
            : (_isQuizFinished 
                ? _buildResultScreen() 
                : _activeQueue.isEmpty 
                    ? const Center(child: Text("No pairs available."))
                    : Column(
                        children: [
                          Expanded(child: _buildQuizContent(borderColor)),
                          _buildBottomActionPanel(borderColor),
                        ],
                      )),
      ),
    );
  }

  Widget _buildStartScreen(Color borderColor) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.compare_arrows_rounded, size: 80.0, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24.0),
            const Text(
              'Jidoushi & Tadoushi',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Guess the verbs based on their meaning. Pairs will appear sequentially (Intransitive ➔ Transitive)!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0, color: Colors.grey, height: 1.4),
            ),
            const SizedBox(height: 48.0),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: borderColor, width: 1.0),
              ),
              child: SwitchListTile(
                title: const Text('Auto-play Audio', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Play pronunciation when checking answer'),
                value: _autoPlayAudio,
                onChanged: (val) => setState(() => _autoPlayAudio = val),
              ),
            ),
            const SizedBox(height: 24.0),
            SizedBox(
              height: 50.0,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _isStarting = false);
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (mounted) _focusNode.requestFocus();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  elevation: 0.0,
                ),
                child: const Text('Start Practice', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizContent(Color borderColor) {
    final currentQ = _activeQueue[_currentIndex];
    final isTransitive = currentQ.type == '他動詞'; 
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              'Pair ${currentQ.number}  •  Question ${_currentIndex + 1} of ${_activeQueue.length}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14.0, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 32.0),
          Text(
            currentQ.translation,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32.0, fontWeight: FontWeight.w800, letterSpacing: -0.5),
          ),
          const SizedBox(height: 12.0),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: isTransitive 
                  ? Colors.blue.withOpacity(0.1) 
                  : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(
                  color: isTransitive ? Colors.blue.withOpacity(0.5) : Colors.orange.withOpacity(0.5), 
                  width: 1.0
                ),
              ),
              child: Text(
                isTransitive ? '他動詞 (Tadoushi / Transitive)' : '自動詞 (Jidoushi / Intransitive)',
                style: TextStyle(
                  color: isTransitive ? Colors.blue.shade700 : Colors.orange.shade700,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32.0),
          TextField(
            controller: _answerController,
            focusNode: _focusNode,
            autofocus: true, 
            readOnly: _isAnswered && _isCorrect, 
            minLines: 1, maxLines: 2, 
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.0, 
              color: (_isAnswered && _isCorrect) 
                  ? Colors.green 
                  : Theme.of(context).colorScheme.onSurface
            ),
            textInputAction: TextInputAction.done, 
            onSubmitted: (_) => _handleSubmitted(''), 
            decoration: InputDecoration(
              hintText: (_isAnswered && !_isCorrect) 
                  ? 'Type the correct answer...' 
                  : 'Type answer in Japanese...',
              hintStyle: TextStyle(fontSize: 15.0, color: Colors.grey.shade400),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: (_isAnswered && !_isCorrect) ? Colors.red.withOpacity(0.5) : borderColor, 
                  width: 1.0
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: (_isAnswered && !_isCorrect) ? Colors.red : Theme.of(context).colorScheme.primary, 
                  width: 2.0
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          if (_showHint)
            Center(
              child: Text(
                'Hint: starts with ${currentQ.japanese[0]}...',
                style: const TextStyle(fontSize: 18.0, fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            )
          else if (!_isAnswered)
            Center(
              child: TextButton.icon(
                onPressed: () => setState(() => _showHint = true),
                icon: const Icon(Icons.lightbulb_outline, size: 18.0),
                label: const Text('Show Hint', style: TextStyle(fontSize: 14.0)),
                style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
              ),
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
              onPressed: _checkAnswer,
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

    final currentQ = _activeQueue[_currentIndex];
    final isLast = _currentIndex >= _activeQueue.length - 1;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final panelColor = _isCorrect ? Colors.green.shade100 : Colors.red.shade100;
    final textColor = _isCorrect ? Colors.green.shade800 : Colors.red.shade800;
    final iconData = _isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded;

    final finalPanelColor = isDark ? (_isCorrect ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15)) : panelColor;
    final finalTextColor = isDark ? (_isCorrect ? Colors.green.shade400 : Colors.red.shade400) : textColor;

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
                  IconButton(
                    icon: Icon(Icons.volume_up_rounded, color: finalTextColor),
                    onPressed: () => _speak(currentQ.japanese),
                  ),
                ],
              ),
              if (!_isCorrect) ...[
                const SizedBox(height: 12.0),
                Text('Correct Answer:', style: TextStyle(color: finalTextColor.withOpacity(0.8), fontSize: 14.0)),
                const SizedBox(height: 4.0),
                Text(
                  currentQ.japanese,
                  style: TextStyle(color: finalTextColor, fontSize: 24.0, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                ),
              ],
              const SizedBox(height: 24.0),
              SizedBox(
                height: 50.0,
                child: ElevatedButton(
                  onPressed: _isCorrect ? _nextQuestion : _checkAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCorrect ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    elevation: 0.0,
                  ),
                  child: Text(
                    _isCorrect ? (isLast ? 'Finish Practice' : 'Continue') : 'Check Correction', 
                    style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== DESAIN BARU RESULT SCREEN =====
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
              label: const Text('Retry Incorrect Words', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
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