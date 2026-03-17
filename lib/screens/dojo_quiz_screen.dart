import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word_model.dart';

class DojoQuizScreen extends StatefulWidget {
  final String kanji;
  final List<WordData> wordList;

  const DojoQuizScreen({super.key, required this.kanji, required this.wordList});

  @override
  State<DojoQuizScreen> createState() => _DojoQuizScreenState();
}

class _DojoQuizScreenState extends State<DojoQuizScreen> {
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  List<WordData> _activeQueue = [];
  List<WordData> _incorrectQueue = [];
  
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
    _activeQueue = List.from(widget.wordList)..shuffle();
  }

  @override
  void dispose() {
    _answerController.dispose();
    _focusNode.dispose();
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

    final currentWord = _activeQueue[_currentIndex];
    
    final userAnswer = _answerController.text.replaceAll(' ', '').replaceAll('　', '').toLowerCase();
    final correctAnswer = currentWord.foundInReading.replaceAll(' ', '').replaceAll('　', '').toLowerCase();

    bool isTextMatch = (userAnswer == correctAnswer);

    setState(() {
      _isAnswered = true; 

      if (isTextMatch) {
        _isCorrect = true;
        _totalCorrect++;
      } else {
        _isCorrect = false;
        _totalWrong++;
        if (!_incorrectQueue.contains(currentWord)) {
          _incorrectQueue.add(currentWord);
        }
      }
    });
    
    _focusNode.requestFocus();
  }

  void _nextQuestion() {
    setState(() {
      _answerController.clear();
      _showHint = false;
      _isAnswered = false; 
      _isCorrect = false;

      if (_currentIndex < _activeQueue.length - 1) {
        _currentIndex++;
        _focusNode.requestFocus(); 
      } else {
        _isQuizFinished = true;
        FocusScope.of(context).unfocus(); 
        if (_incorrectQueue.isEmpty) {
          _saveClearStatus();
        }
      }
    });
  }

  Future<void> _saveClearStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await prefs.setInt('dojo_${widget.kanji}', currentTime);
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

  @override
  Widget build(BuildContext context) {
    if (_isQuizFinished) {
      return _buildResultScreen();
    }

    final currentWord = _activeQueue[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Dojo: ${widget.kanji}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: (_currentIndex + 1) / _activeQueue.length,
            backgroundColor: Colors.grey.withOpacity(0.2),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24.0, 
            right: 24.0, 
            top: 16.0, 
            bottom: MediaQuery.of(context).padding.bottom + 24.0
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Question ${_currentIndex + 1} of ${_activeQueue.length}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Text(
                currentWord.foundInCharacters,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_showHint)
                Text(
                  'Meaning: ${currentWord.foundInMeaning}',
                  style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Colors.grey),
                )
              else
                TextButton.icon(
                  onPressed: () => setState(() => _showHint = true),
                  icon: const Icon(Icons.lightbulb_outline, size: 18),
                  label: const Text('Show Hint', style: TextStyle(fontSize: 14)),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
                ),
              const SizedBox(height: 24),
              
              TextField(
                controller: _answerController,
                focusNode: _focusNode,
                autofocus: true, 
                readOnly: _isAnswered, 
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20, 
                  color: _isAnswered 
                      ? (_isCorrect ? Colors.green : Colors.red) 
                      : Theme.of(context).colorScheme.onSurface
                ),
                textInputAction: TextInputAction.done, 
                onSubmitted: _handleSubmitted, 
                decoration: InputDecoration(
                  hintText: 'Type reading (hiragana)...',
                  hintStyle: const TextStyle(fontSize: 16),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: Column(
                  children: [
                    if (_isAnswered) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          color: _isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isCorrect ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
                            width: 1.5,
                          )
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                  color: _isCorrect ? Colors.green : Colors.red,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isCorrect ? 'Correct!' : 'Incorrect!',
                                  style: TextStyle(
                                    fontSize: 20, 
                                    fontWeight: FontWeight.bold,
                                    color: _isCorrect ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            if (!_isCorrect) ...[
                              const SizedBox(height: 8),
                              const Text('Correct reading is:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text(
                                currentWord.foundInReading,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ]
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isAnswered ? _nextQuestion : _checkAnswer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isAnswered 
                              ? Theme.of(context).colorScheme.secondaryContainer 
                              : Theme.of(context).colorScheme.primary,
                          foregroundColor: _isAnswered 
                              ? Theme.of(context).colorScheme.onSecondaryContainer 
                              : Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text(
                          _isAnswered 
                              ? (_currentIndex < _activeQueue.length - 1 ? 'Next' : 'Finish') 
                              : 'Check', 
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ),
                  ],
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dojo Results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: 24.0, 
          right: 24.0, 
          top: 24.0, 
          bottom: MediaQuery.of(context).padding.bottom + 48.0
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              isPerfect ? Icons.workspace_premium_rounded : Icons.fitness_center_rounded,
              size: 80,
              color: isPerfect ? Colors.amber : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              isPerfect ? 'Stage Cleared!' : 'Keep Practicing!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
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
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Retry Incorrect Words', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context, true); 
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Back to List', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, int value, Color color) {
    return Column(
      children: [
        Text(value.toString(), style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}