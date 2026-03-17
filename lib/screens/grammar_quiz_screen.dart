import 'package:flutter/material.dart';
import '../models/grammar_model.dart';

class GrammarQuizScreen extends StatefulWidget {
  final String chapter;
  final List<GrammarData> grammarList;

  const GrammarQuizScreen({super.key, required this.chapter, required this.grammarList});

  @override
  State<GrammarQuizScreen> createState() => _GrammarQuizScreenState();
}

class _GrammarQuizScreenState extends State<GrammarQuizScreen> {
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<GrammarData> _activeQueue = [];
  List<GrammarData> _incorrectQueue = [];

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
    _activeQueue = List.from(widget.grammarList);
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

    FocusScope.of(context).unfocus();

    final currentData = _activeQueue[_currentIndex];
    final userAnswer = _answerController.text.replaceAll(' ', '').replaceAll('　', '').toLowerCase();
    final correctAnswer = currentData.sentence.replaceAll(' ', '').replaceAll('　', '').toLowerCase();

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
    final String title = _isQuizFinished ? 'Leave Results?' : 'Exit Challenge?';
    final String content = _isQuizFinished 
        ? 'Are you sure you want to return to the menu?' 
        : 'You have not finished this challenge. Are you sure you want to leave?';

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
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
          title: Text(widget.chapter, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: LinearProgressIndicator(
              value: _isQuizFinished ? 1.0 : (_currentIndex + 1) / _activeQueue.length,
              backgroundColor: Colors.grey.withOpacity(0.2),
            ),
          ),
        ),
        body: _isQuizFinished 
            ? _buildResultScreen() 
            : Column(
                children: [
                  Expanded(
                    child: _buildQuizContent(),
                  ),
                  _buildBottomActionPanel(),
                ],
              ),
      ),
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
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          if (currentData.number.isNotEmpty)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Pattern / Part ${currentData.number}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 32),
          Text(
            currentData.translation,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.4),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _answerController,
            focusNode: _focusNode,
            autofocus: true,
            readOnly: _isAnswered,
            minLines: 1, 
            maxLines: 3, 
            style: TextStyle(
              fontSize: 18,
              color: _isAnswered 
                  ? (_isCorrect ? Colors.green : Colors.red) 
                  : Theme.of(context).colorScheme.onSurface,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleSubmitted(''),
            decoration: InputDecoration(
              hintText: 'Type the Japanese sentence...',
              hintStyle: TextStyle(fontSize: 15, color: Colors.grey.shade400),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_showHint)
            Center(
              child: Text(
                'Hint: ${currentData.sentence.substring(0, currentData.sentence.length > 2 ? 2 : 1)}...',
                style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            )
          else if (!_isAnswered)
            Center( 
              child: TextButton.icon(
                onPressed: () => setState(() => _showHint = true),
                icon: const Icon(Icons.lightbulb_outline, size: 18),
                label: const Text('Show Hint', style: TextStyle(fontSize: 14)),
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Check Answer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  Icon(iconData, color: finalTextColor, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isCorrect ? 'Excellent!' : 'Incorrect',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: finalTextColor),
                    ),
                  ),
                ],
              ),
              if (!_isCorrect) ...[
                const SizedBox(height: 12),
                Text('Correct Answer:', style: TextStyle(color: finalTextColor.withOpacity(0.8), fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  currentData.sentence,
                  style: TextStyle(color: finalTextColor, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCorrect ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    isLast ? 'Finish Challenge' : 'Continue', 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
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
              child: const Text('Retry Incorrect Sentences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                Navigator.pop(context, true);
              }
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Back to Menu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
        ],
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