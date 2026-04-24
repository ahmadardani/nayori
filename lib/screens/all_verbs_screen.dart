import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/verb_model.dart';
import 'verb_quiz_screen.dart';

class AllVerbsScreen extends StatefulWidget {
  final String title;
  final List<String> jsonPaths;

  const AllVerbsScreen({super.key, required this.title, required this.jsonPaths});

  @override
  State<AllVerbsScreen> createState() => _AllVerbsScreenState();
}

class _AllVerbsScreenState extends State<AllVerbsScreen> {
  bool _isLoading = true;
  List<VerbData> _allVerbs = [];
  Map<String, Map<String, List<VerbData>>> _groupedVerbs = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      List<VerbData> combinedVerbs = [];
      for (String path in widget.jsonPaths) {
        final String jsonString = await rootBundle.loadString(path);
        final result = await compute(parseVerbDataInBackground, jsonString);
        combinedVerbs.addAll(result.allVerbs);
      }

      Map<String, Map<String, List<VerbData>>> tempGroups = {};
      for (var verb in combinedVerbs) {
        if (verb.group.trim().isEmpty) continue; 
        
        if (!tempGroups.containsKey(verb.group)) {
          tempGroups[verb.group] = {};
        }
        if (!tempGroups[verb.group]!.containsKey(verb.subGroup)) {
          tempGroups[verb.group]![verb.subGroup] = [];
        }
        tempGroups[verb.group]![verb.subGroup]!.add(verb);
      }

      setState(() {
        _allVerbs = combinedVerbs;
        _groupedVerbs = tempGroups;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading verbs: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w600))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.only(
                left: 16.0, right: 16.0, top: 16.0,
                bottom: MediaQuery.of(context).padding.bottom + 16.0,
              ),
              itemCount: _groupedVerbs.keys.length + 1,
              itemBuilder: (context, index) {
                
                if (index == 0) {
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 1.0,
                    margin: const EdgeInsets.only(bottom: 24.0),
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      leading: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.all_inclusive_rounded, color: Theme.of(context).colorScheme.onPrimary),
                      ),
                      title: const Text('Semua Kategori (Campuran)', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                      subtitle: Text('${_allVerbs.length} Kata Kerja Tersedia'),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => VerbListDetailScreen(
                              title: 'Semua Kategori',
                              verbs: _allVerbs,
                            ),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                    ),
                  );
                }

                final groupName = _groupedVerbs.keys.elementAt(index - 1);
                final subGroupsMap = _groupedVerbs[groupName]!;
                
                int totalVerbsInGroup = subGroupsMap.values.fold(0, (sum, list) => sum + list.length);

                IconData groupIcon = Icons.category_rounded;
                if (groupName.toLowerCase().contains('godan') || groupName.contains('1')) groupIcon = Icons.looks_one_rounded;
                if (groupName.toLowerCase().contains('ichidan') || groupName.contains('2')) groupIcon = Icons.looks_two_rounded;
                if (groupName.toLowerCase().contains('suru') || groupName.toLowerCase().contains('kuru') || groupName.contains('3')) groupIcon = Icons.looks_3_rounded;

                return Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 1.0,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    leading: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Icon(groupIcon, color: Theme.of(context).colorScheme.onSecondaryContainer),
                    ),
                    title: Text(groupName, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                    subtitle: Text('$totalVerbsInGroup Kata Kerja'),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => VerbSubGroupScreen(
                            groupName: groupName,
                            subGroupsMap: subGroupsMap,
                          ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class VerbSubGroupScreen extends StatelessWidget {
  final String groupName;
  final Map<String, List<VerbData>> subGroupsMap;

  const VerbSubGroupScreen({super.key, required this.groupName, required this.subGroupsMap});

  @override
  Widget build(BuildContext context) {
    final subGroupNames = subGroupsMap.keys.toList();
    int totalVerbsInGroup = subGroupsMap.values.fold(0, (sum, list) => sum + list.length);

    return Scaffold(
      appBar: AppBar(title: Text(groupName, style: const TextStyle(fontWeight: FontWeight.w600))),
      body: ListView.builder(
        padding: EdgeInsets.only(
          left: 16.0, right: 16.0, top: 16.0,
          bottom: MediaQuery.of(context).padding.bottom + 16.0,
        ),
        itemCount: subGroupNames.length + 1,
        itemBuilder: (context, index) {
          
          if (index == 0) {
            return Card(
              clipBehavior: Clip.antiAlias,
              elevation: 1.0,
              margin: const EdgeInsets.only(bottom: 24.0),
              color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.5),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                leading: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.list_alt_rounded, color: Theme.of(context).colorScheme.onTertiary),
                ),
                title: const Text('Semua Sub-group', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                subtitle: Text('$totalVerbsInGroup kata dalam grup ini'),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                onTap: () {
                  List<VerbData> allGroupVerbs = [];
                  for (var list in subGroupsMap.values) {
                    allGroupVerbs.addAll(list);
                  }
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => VerbListDetailScreen(
                        title: groupName,
                        verbs: allGroupVerbs,
                      ),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
              ),
            );
          }

          final subGroupName = subGroupNames[index - 1];
          final verbsInSubGroup = subGroupsMap[subGroupName]!;

          return Card(
            clipBehavior: Clip.antiAlias,
            elevation: 0.0,
            margin: const EdgeInsets.only(bottom: 8.0),
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              title: Text('Akhiran $subGroupName', style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${verbsInSubGroup.length} kata', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(width: 8.0),
                  const Icon(Icons.chevron_right_rounded, size: 20.0, color: Colors.grey),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => VerbListDetailScreen(
                      title: '$groupName ($subGroupName)',
                      verbs: verbsInSubGroup,
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class VerbListDetailScreen extends StatefulWidget {
  final String title;
  final List<VerbData> verbs;

  const VerbListDetailScreen({super.key, required this.title, required this.verbs});

  @override
  State<VerbListDetailScreen> createState() => _VerbListDetailScreenState();
}

class _VerbListDetailScreenState extends State<VerbListDetailScreen> {
  List<VerbData> _filteredVerbs = [];
  final TextEditingController _searchController = TextEditingController();
  final FlutterTts flutterTts = FlutterTts();
  
  @override
  void initState() {
    super.initState();
    _filteredVerbs = widget.verbs;
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("ja-JP");
    await flutterTts.setSpeechRate(0.45);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _filterVerbs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredVerbs = widget.verbs.where((v) {
        return query.isEmpty || 
            v.kanji.contains(query) || 
            v.meaning.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w600))),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _filterVerbs(), 
              decoration: InputDecoration(
                hintText: 'Search verb or meaning...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterVerbs();
                        },
                      )
                    : null,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
              ),
            ),
          ),
          
          Expanded(child: _buildVerbList(_filteredVerbs)),
        ],
      ),
      floatingActionButton: _filteredVerbs.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => VerbQuizScreen(
                      title: widget.title,
                      verbList: _filteredVerbs, 
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              icon: const Icon(Icons.fitness_center_rounded),
              label: const Text('Start Dojo', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildVerbList(List<VerbData> verbs) {
    if (verbs.isEmpty) {
      return const Center(child: Text('No verbs found.', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 8.0, 
        bottom: MediaQuery.of(context).padding.bottom + 100.0,
      ),
      itemCount: verbs.length,
      itemBuilder: (context, index) {
        final verb = verbs[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.only(bottom: 12.0),
          child: ExpansionTile(
            title: Row(
              children: [
                Expanded(
                  child: Text(verb.kanji, style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            subtitle: Text(verb.meaning),
            childrenPadding: const EdgeInsets.all(16.0),
            children: [
              if (verb.dictionary.isNotEmpty) _buildFormRow('Dictionary', verb.dictionary),
              if (verb.masuForm.isNotEmpty) _buildFormRow('Masu Form', verb.masuForm),
              if (verb.naiForm.isNotEmpty) _buildFormRow('Nai Form', verb.naiForm),
              if (verb.taForm.isNotEmpty) _buildFormRow('Ta Form', verb.taForm),
              if (verb.nakattaForm.isNotEmpty) _buildFormRow('Nakatta Form', verb.nakattaForm),
              if (verb.teForm.isNotEmpty) _buildFormRow('Te Form', verb.teForm),
              if (verb.potential.isNotEmpty) _buildFormRow('Potential', verb.potential),
              if (verb.volitional.isNotEmpty) _buildFormRow('Volitional', verb.volitional),
              if (verb.teKudasai.isNotEmpty) _buildFormRow('Te Kudasai', verb.teKudasai),
              if (verb.teIru.isNotEmpty) _buildFormRow('Te Iru', verb.teIru),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormRow(String label, String formText) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
            Row(
              children: [
                Text(formText, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8.0),
                GestureDetector(
                  onTap: () => _speak(formText),
                  child: Icon(Icons.volume_up_rounded, color: Theme.of(context).colorScheme.primary, size: 20.0),
                )
              ],
            )
          ],
        ),
        const Divider(),
      ],
    );
  }
}