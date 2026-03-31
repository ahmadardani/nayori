import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/verb_model.dart';

class VerbQuestion {
  final VerbData verb;
  final String formName;
  final String correctAnswer;
  VerbQuestion(this.verb, this.formName, this.correctAnswer);
}

class VerbQuizScreen extends StatefulWidget {
  final String title;
  final List<VerbData> verbList;

  const VerbQuizScreen({super.key, required this.title, required this.verbList});

  @override
  State<VerbQuizScreen> createState() => _VerbQuizScreenState();
}

class _VerbQuizScreenState extends State<VerbQuizScreen> {
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FlutterTts flutterTts = FlutterTts(); 
  
  List<VerbQuestion> _activeQueue = [];
  List<VerbQuestion> _incorrectQueue = [];
  
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
    _generateQuestions();
  }

  void _generateQuestions() {
    List<VerbQuestion> questions = [];
    for (var verb in widget.verbList) {
      if (verb.masuForm.isNotEmpty) questions.add(VerbQuestion(verb, 'Masu Form', verb.masuForm));
      if (verb.naiForm.isNotEmpty) questions.add(VerbQuestion(verb, 'Nai Form', verb.naiForm));
      if (verb.taForm.isNotEmpty) questions.add(VerbQuestion(verb, 'Ta Form', verb.taForm));
      if (verb.nakattaForm.isNotEmpty) questions.add(VerbQuestion(verb, 'Nakatta Form', verb.nakattaForm));
      if (verb.teForm.isNotEmpty) questions.add(VerbQuestion(verb, 'Te Form', verb.teForm));
      if (verb.potential.isNotEmpty) questions.add(VerbQuestion(verb, 'Potential Form', verb.potential));
      if (verb.volitional.isNotEmpty) questions.add(VerbQuestion(verb, 'Volitional Form', verb.volitional));
      if (verb.teKudasai.isNotEmpty) questions.add(VerbQuestion(verb, 'Te Kudasai', verb.teKudasai));
      if (verb.teIru.isNotEmpty) questions.add(VerbQuestion(verb, 'Te Iru', verb.teIru));
    }
    _activeQueue = List.from(questions)..shuffle(); 
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
    final correctAnswer = normalizeText(currentQ.correctAnswer);
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
        _speak(currentQ.correctAnswer); 
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
      _activeQueue = List.from(_incorrectQueue)..shuffle();
      _incorrectQueue.clear();
      _currentIndex = 0;
      _totalCorrect = 0;
      _totalWrong = 0;
      _isQuizFinished = false;
      _focusNode.requestFocus(); 
    });
  }

  Future<bool> _onWillPop() async {
    if (_isQuizFinished) return true;
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
        if (shouldPop && context.mounted) Navigator.pop(context, true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Dojo: ${widget.title}', 
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: LinearProgressIndicator(
              value: _isQuizFinished ? 1.0 : (_currentIndex + 1) / _activeQueue.length,
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
            : Column(
                children: [
                  Expanded(child: _buildQuizContent()),
                  _buildBottomActionPanel(),
                ],
              ),
      ),
    );
  }

  Widget _buildQuizContent() {
    final currentQ = _activeQueue[_currentIndex];
    
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
            currentQ.verb.kanji,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          Text(
            currentQ.verb.meaning,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16.0, color: Colors.grey),
          ),
          const SizedBox(height: 24.0),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                'Change to: ${currentQ.formName}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
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
            minLines: 1, 
            maxLines: 2, 
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
              hintText: (_isAnswered && !_isCorrect) ? 'Type the correct answer...' : 'Type answer in Japanese...',
              hintStyle: TextStyle(fontSize: 15.0, color: Colors.grey.shade400),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide(
                  color: (_isAnswered && !_isCorrect) ? Colors.red.withOpacity(0.5) : Colors.grey.withOpacity(0.3), 
                  width: 1.5
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
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
                'Hint: starts with ${currentQ.correctAnswer.substring(0, 1)}...',
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
    final currentQ = _activeQueue[_currentIndex];

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

    final isLast = _currentIndex >= _activeQueue.length - 1;
    final panelColor = _isCorrect ? Colors.green.shade100 : Colors.red.shade100;
    final textColor = _isCorrect ? Colors.green.shade800 : Colors.red.shade800;
    final iconData = _isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final finalPanelColor = isDark ? (_isCorrect ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2)) : panelColor;
    final finalTextColor = isDark ? (_isCorrect ? Colors.green.shade300 : Colors.red.shade300) : textColor;

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
                    onPressed: () => _speak(currentQ.correctAnswer),
                  ),
                ],
              ),
              if (!_isCorrect) ...[
                const SizedBox(height: 12.0),
                Text('Correct Answer:', style: TextStyle(color: finalTextColor.withOpacity(0.8), fontSize: 14.0)),
                const SizedBox(height: 4.0),
                Text(
                  currentQ.correctAnswer,
                  style: TextStyle(color: finalTextColor, fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
              ],
              const SizedBox(height: 24.0),
              SizedBox(
                height: 56.0,
                child: ElevatedButton(
                  onPressed: _isCorrect ? _nextQuestion : _checkAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCorrect ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                    elevation: 0.0,
                  ),
                  child: Text(
                    _isCorrect ? (isLast ? 'Finish Challenge' : 'Continue') : 'Check Correction', 
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
        left: 24.0, right: 24.0, top: 24.0, 
        bottom: MediaQuery.of(context).padding.bottom + 48.0
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            isPerfect ? Icons.workspace_premium_rounded : Icons.fitness_center_rounded,
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
              child: const Text('Retry Incorrect Words', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(height: 12.0),
          OutlinedButton(
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) Navigator.pop(context, true); 
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            ),
            child: const Text('Back to List', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
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