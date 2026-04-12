import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/sentence_model.dart';

class SentenceQuizScreen extends StatefulWidget {
  const SentenceQuizScreen({super.key});

  @override
  State<SentenceQuizScreen> createState() => _SentenceQuizScreenState();
}

class _SentenceQuizScreenState extends State<SentenceQuizScreen> {
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FlutterTts flutterTts = FlutterTts(); 
  
  List<SentencePairData> _allSentences = [];
  List<SentencePairData> _activeQueue = [];
  List<SentencePairData> _incorrectQueue = [];
  
  bool _isLoading = true;
  bool _autoPlayAudio = true; 
  
  bool _isQuizStarted = false;
  String? _selectedType; 
  
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
    _loadData();
    _initTts(); 
  }

  Future<void> _loadData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/Jidoushi_Tadoushi_Pairs.json');
      final List<dynamic> parsedJson = json.decode(jsonString);
      setState(() {
        _allSentences = parsedJson.map((json) => SentencePairData.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading sentences: $e");
      setState(() => _isLoading = false);
    }
  }

  void _startQuiz(String levelStr) {
    setState(() {
      var filtered = _allSentences.where((s) {
        bool matchLevel = levelStr == 'Semua Level' || 'Level ${s.level}' == levelStr;
        bool matchType = true;
        if (_selectedType == 'intransitive') {
          matchType = s.type == 'intransitive';
        } else if (_selectedType == 'transitive') {
          matchType = s.type == 'transitive';
        }
        return matchLevel && matchType;
      }).toList();

      _activeQueue = List.from(filtered);
      
      if (levelStr == 'Semua Level' || _selectedType == 'mixed') {
        _activeQueue.shuffle();
      }

      _isQuizStarted = true;
    });
    
    if (_activeQueue.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("ja-JP");
    await flutterTts.setSpeechRate(0.45); 
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
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
    final correctAnswer = normalizeText(currentQ.japanese);
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
    if (!_isQuizStarted) {
      if (_selectedType != null) {
        setState(() => _selectedType = null);
        return false;
      }
      return true; 
    }
    if (_isQuizFinished) return true;
    
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    if (!_isQuizStarted) {
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          if (_selectedType != null) {
            setState(() => _selectedType = null);
          } else {
            Navigator.pop(context);
          }
        },
        child: Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: bgColor,
            title: const Text('Sentence Practice', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            centerTitle: true,
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _selectedType == null 
                ? _buildTypeSelectionMenu(borderColor) 
                : _buildLevelSelectionMenu(borderColor),
          ),
        ),
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
          title: const Text(
            'Translation Practice', 
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w800, letterSpacing: -0.5)
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: LinearProgressIndicator(
              value: _isQuizFinished || _activeQueue.isEmpty ? 1.0 : (_currentIndex + 1) / _activeQueue.length,
              backgroundColor: Colors.grey.withOpacity(0.2),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(_autoPlayAudio ? Icons.volume_up_rounded : Icons.volume_off_rounded),
              tooltip: 'Toggle Auto-play Audio',
              onPressed: () => setState(() => _autoPlayAudio = !_autoPlayAudio),
            ),
          ],
        ),
        body: _isQuizFinished 
            ? _buildResultScreen() 
            : _activeQueue.isEmpty 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("No questions available for this combination."),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () => setState(() {
                            _isQuizStarted = false;
                            _selectedType = null;
                          }),
                          style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
                          child: const Text('Back to Menu'),
                        )
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(child: _buildQuizContent(borderColor)),
                      _buildBottomActionPanel(borderColor),
                    ],
                  ),
      ),
    );
  }

  Widget _buildTypeSelectionMenu(Color borderColor) {
    return Center(
      key: const ValueKey('TypeMenu'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.compare_arrows_rounded, size: 64.0, color: Colors.grey),
            const SizedBox(height: 16.0),
            const Text(
              'Step 1: Select Verb Type',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w800, letterSpacing: -0.5),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Choose the focus of your practice session today.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.0, color: Colors.grey),
            ),
            const SizedBox(height: 48.0),
            
            _buildBigMenuButton(
              title: 'Intransitive (Jidoushi)',
              subtitle: 'Focus on particle が',
              icon: Icons.person_rounded,
              color: Colors.green.shade700,
              borderColor: borderColor,
              onTap: () => setState(() => _selectedType = 'intransitive'),
            ),
            const SizedBox(height: 16.0),
            
            _buildBigMenuButton(
              title: 'Transitive (Tadoushi)',
              subtitle: 'Focus on particle を',
              icon: Icons.front_hand_rounded,
              color: Colors.blue.shade700,
              borderColor: borderColor,
              onTap: () => setState(() => _selectedType = 'transitive'),
            ),
            const SizedBox(height: 16.0),
            
            _buildBigMenuButton(
              title: 'Mixed (Random)',
              subtitle: 'Test instincts on both types',
              icon: Icons.shuffle_rounded,
              color: Theme.of(context).colorScheme.primary,
              borderColor: borderColor,
              onTap: () => setState(() => _selectedType = 'mixed'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelSelectionMenu(Color borderColor) {
    final levelsSet = _allSentences.map((s) => s.level).toSet().toList();
    levelsSet.sort();

    return Center(
      key: const ValueKey('LevelMenu'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => setState(() => _selectedType = null),
                tooltip: 'Back to type selection',
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Step 2: Select Level',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w800, letterSpacing: -0.5),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Selected: ${_selectedType == 'mixed' ? 'Mixed' : _selectedType == 'intransitive' ? 'Jidoushi' : 'Tadoushi'}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.0, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32.0),
            
            ElevatedButton(
              onPressed: () => _startQuiz('Semua Level'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              child: const Text('Start All Levels (Random)', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Or select by level', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
            ),

            ...levelsSet.map((levelNum) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: OutlinedButton(
                onPressed: () => _startQuiz('Level $levelNum'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  side: BorderSide(color: borderColor, width: 1.0),
                ),
                child: Text('Level $levelNum (Sequential)', style: TextStyle(fontSize: 16.0, color: Theme.of(context).colorScheme.onSurface)),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBigMenuButton({required String title, required String subtitle, required IconData icon, required Color color, required Color borderColor, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1.0),
          borderRadius: BorderRadius.circular(8.0),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(icon, color: color, size: 28.0),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, letterSpacing: -0.3)),
                  const SizedBox(height: 4.0),
                  Text(subtitle, style: TextStyle(fontSize: 14.0, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizContent(Color borderColor) {
    final currentQ = _activeQueue[_currentIndex];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              'Question ${_currentIndex + 1} of ${_activeQueue.length} (Level ${currentQ.level})',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14.0, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 32.0),
          Text(
            currentQ.indonesian,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28.0, fontWeight: FontWeight.w800, letterSpacing: -0.5),
          ),
          const SizedBox(height: 12.0),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5), width: 1.0),
              ),
              child: Text(
                'Type: ${currentQ.type == 'transitive' ? '他 (Tadoushi)' : '自 (Jidoushi)'}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48.0),
          TextField(
            controller: _answerController,
            focusNode: _focusNode,
            autofocus: true, 
            readOnly: _isAnswered && _isCorrect, 
            minLines: 1, 
            maxLines: 3, 
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0, 
              color: (_isAnswered && _isCorrect) 
                  ? Colors.green 
                  : Theme.of(context).colorScheme.onSurface
            ),
            textInputAction: TextInputAction.done, 
            onSubmitted: (_) => _handleSubmitted(''), 
            decoration: InputDecoration(
              hintText: (_isAnswered && !_isCorrect) 
                  ? 'Type the correct sentence...' 
                  : 'Type in Japanese...',
              hintStyle: TextStyle(fontSize: 15.0, color: Colors.grey.shade400),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
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
                'Hint: starts with ${currentQ.japanese.substring(0, 1)}...',
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
                  style: TextStyle(color: finalTextColor, fontSize: 22.0, fontWeight: FontWeight.w800, letterSpacing: -0.5),
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
            size: 80.0,
            color: isPerfect ? Colors.amber : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16.0),
          Text(
            isPerfect ? 'Practice Cleared!' : 'Keep Practicing!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28.0, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
          const SizedBox(height: 32.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn('Correct', _totalCorrect, Colors.green),
              _buildStatColumn('Incorrect', _totalWrong, Colors.red),
            ],
          ),
          const Spacer(),
          if (!isPerfect)
            ElevatedButton(
              onPressed: _retryIncorrect,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                elevation: 0.0,
              ),
              child: const Text('Retry Incorrect Sentences', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(height: 12.0),
          OutlinedButton(
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) Navigator.pop(context, true); 
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
            child: const Text('Back to Menu', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, int value, Color color) {
    return Column(
      children: [
        Text(value.toString(), style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: const TextStyle(fontSize: 14.0, color: Colors.grey)),
      ],
    );
  }
}