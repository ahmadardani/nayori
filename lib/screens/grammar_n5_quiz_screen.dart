import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/grammar_n5_model.dart';

class GrammarN5QuizScreen extends StatefulWidget {
  final GrammarN5Data data;

  const GrammarN5QuizScreen({super.key, required this.data});

  @override
  State<GrammarN5QuizScreen> createState() => _GrammarN5QuizScreenState();
}

class _GrammarN5QuizScreenState extends State<GrammarN5QuizScreen> {
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FlutterTts flutterTts = FlutterTts();
  
  List<GrammarN5Sentence> _activeQueue = [];
  List<GrammarN5Sentence> _incorrectQueue = [];
  
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
    // DIHAPUS .shuffle() AGAR URUTAN SESUAI JSON
    _activeQueue = List.from(widget.data.quizSentences);
    _initTts(); 
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
    } else {
      _nextQuestion();
    }
  }

  void _checkAnswer() {
    if (_answerController.text.trim().isEmpty) return;

    FocusScope.of(context).unfocus(); 

    final currentData = _activeQueue[_currentIndex];
    
    String normalizeText(String text) {
      String normalized = text
          .replaceAll(' ', '')
          .replaceAll('　', '')  
          .replaceAll('。', '')  
          .replaceAll('、', '')  
          .replaceAll(',', '')   
          .replaceAll('？', '')  
          .replaceAll('?', '')   
          .replaceAll('！', '')  
          .replaceAll('!', '')   
          .toLowerCase();
      
      normalized = normalized.replaceAll('才', '歳');
      
      const fullWidth = 'ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ１２３４５６７８９０';
      const halfWidth = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890';
      
      for (int i = 0; i < fullWidth.length; i++) {
        normalized = normalized.replaceAll(fullWidth[i], halfWidth[i].toLowerCase());
      }
      
      return normalized;
    }

    final userAnswer = normalizeText(_answerController.text);
    final correctAnswer = normalizeText(currentData.japanese);

    bool isTextMatch = (userAnswer == correctAnswer);

    setState(() {
      _isAnswered = true;
      if (isTextMatch) {
        _isCorrect = true;
        _totalCorrect++;
      } else {
        _isCorrect = false;
        _totalWrong++;
        if (!_incorrectQueue.contains(currentData)) {
          _incorrectQueue.add(currentData);
        }
      }
    });

    if (_autoPlayAudio) {
      _speak(currentData.japanese);
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
      // DIHAPUS .shuffle() AGAR URUTAN MENGULANG TETAP STABIL
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
        title: const Text('Exit Challenge?'),
        content: const Text('You have not finished this challenge. Are you sure you want to leave?'),
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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.data.title, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
          centerTitle: true,
          bottom: _isStarting 
            ? null 
            : PreferredSize(
                preferredSize: const Size.fromHeight(4.0),
                child: LinearProgressIndicator(
                  value: _isQuizFinished ? 1.0 : (_currentIndex + 1) / _activeQueue.length,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                ),
              ),
        ),
        body: _isStarting 
            ? _buildStartScreen() 
            : (_isQuizFinished 
                ? _buildResultScreen() 
                : Column(
                    children: [
                      Expanded(
                        child: _buildQuizContent(),
                      ),
                      _buildBottomActionPanel(),
                    ],
                  )),
      ),
    );
  }

  Widget _buildStartScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.translate_rounded, size: 80.0, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 24.0),
                Text(
                  widget.data.title, 
                  textAlign: TextAlign.center, 
                  style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Ready to test your grammar?', 
                  textAlign: TextAlign.center, 
                  style: TextStyle(fontSize: 16.0, color: Colors.grey)
                ),
                const SizedBox(height: 48.0),
                Card(
                  elevation: 0.0,
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  child: SwitchListTile(
                    title: const Text('Auto-play Audio', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Play pronunciation when checking answer'),
                    value: _autoPlayAudio,
                    onChanged: (val) => setState(() => _autoPlayAudio = val),
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24.0, right: 24.0, top: 16.0, 
              bottom: MediaQuery.of(context).padding.bottom > 0 ? 8.0 : 24.0
            ),
            child: SizedBox(
              height: 56.0,
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                  elevation: 0.0,
                ),
                child: const Text('Start Challenge', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizContent() {
    final currentData = _activeQueue[_currentIndex];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              'Question ${_currentIndex + 1} of ${_activeQueue.length}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14.0, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 32.0),
          Text(
            currentData.indonesian,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, height: 1.4),
          ),
          const SizedBox(height: 12.0),
          Text(
            currentData.english,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16.0, color: Colors.grey, height: 1.3),
          ),
          const SizedBox(height: 32.0),
          TextField(
            controller: _answerController,
            focusNode: _focusNode,
            autofocus: true,
            readOnly: _isAnswered,
            minLines: 1, 
            maxLines: 3, 
            style: TextStyle(
              fontSize: 18.0, 
              color: _isAnswered 
                  ? (_isCorrect ? Colors.green : Colors.red) 
                  : Theme.of(context).colorScheme.onSurface,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleSubmitted(''),
            decoration: InputDecoration(
              hintText: 'Type the Japanese sentence...',
              hintStyle: TextStyle(fontSize: 15.0, color: Colors.grey.shade400),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          if (_showHint)
            Center(
              child: Text(
                'Hint: ${currentData.japanese.substring(0, currentData.japanese.length > 2 ? 2 : 1)}...',
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

  Widget _buildBottomActionPanel() {
    final colorScheme = Theme.of(context).colorScheme;

    if (!_isAnswered) {
      return SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56.0,
            child: ElevatedButton(
              onPressed: _checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                elevation: 0.0,
              ),
              child: const Text('Check Answer', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      );
    }

    final currentData = _activeQueue[_currentIndex];
    final isLast = _currentIndex >= _activeQueue.length - 1;
    final panelColor = _isCorrect ? Colors.green.shade100 : Colors.red.shade100;
    final textColor = _isCorrect ? Colors.green.shade800 : Colors.red.shade800;
    final iconData = _isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final finalPanelColor = isDark 
        ? (_isCorrect ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2)) 
        : panelColor;
    final finalTextColor = isDark 
        ? (_isCorrect ? Colors.green.shade300 : Colors.red.shade300) 
        : textColor;

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
                  Icon(iconData, color: finalTextColor, size: 32.0),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      _isCorrect ? 'Excellent!' : 'Incorrect',
                      style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: finalTextColor),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.volume_up_rounded, color: finalTextColor),
                    onPressed: () => _speak(currentData.japanese),
                  ),
                ],
              ),
              if (!_isCorrect) ...[
                const SizedBox(height: 12.0),
                Text('Correct Answer:', style: TextStyle(color: finalTextColor.withOpacity(0.8), fontSize: 14.0)),
                const SizedBox(height: 4.0),
                Text(
                  currentData.japanese,
                  style: TextStyle(color: finalTextColor, fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4.0),
                Text(
                  currentData.romaji,
                  style: TextStyle(color: finalTextColor.withOpacity(0.8), fontSize: 14.0, fontStyle: FontStyle.italic),
                ),
              ],
              const SizedBox(height: 24.0),
              SizedBox(
                height: 56.0,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCorrect ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                    elevation: 0.0,
                  ),
                  child: Text(
                    isLast ? 'Finish Challenge' : 'Continue', 
                    style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)
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
        left: 24.0,
        right: 24.0,
        top: 24.0,
        bottom: MediaQuery.of(context).padding.bottom + 48.0, 
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
            isPerfect ? 'Stage Cleared!' : 'Keep Practicing!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                elevation: 0.0,
              ),
              child: const Text('Retry Incorrect Sentences', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(height: 12.0),
          OutlinedButton(
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                Navigator.pop(context, true);
              }
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
        Text(value.toString(), style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 14.0, color: Colors.grey)),
      ],
    );
  }
}