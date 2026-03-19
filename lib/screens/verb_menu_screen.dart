import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/verb_model.dart';
import 'verb_quiz_screen.dart';

class VerbMenuScreen extends StatefulWidget {
  const VerbMenuScreen({super.key});

  @override
  State<VerbMenuScreen> createState() => _VerbMenuScreenState();
}

class _VerbMenuScreenState extends State<VerbMenuScreen> {
  bool _isLoading = true;
  List<VerbData> _allVerbs = [];
  Map<String, List<String>> _groupedSubGroups = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/N5_Verbs_C1.json');
      final result = await compute(parseVerbDataInBackground, jsonString);
      setState(() {
        _allVerbs = result.allVerbs;
        _groupedSubGroups = result.groupedSubGroups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verb Groups')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.only(
                left: 16.0, 
                right: 16.0, 
                top: 16.0, 
                bottom: MediaQuery.of(context).padding.bottom + 16.0, 
              ),
              itemCount: _groupedSubGroups.keys.length,
              itemBuilder: (context, index) {
                final group = _groupedSubGroups.keys.elementAt(index);
                final subGroups = _groupedSubGroups[group]!;

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
                      child: Icon(Icons.folder_open_rounded, color: Theme.of(context).colorScheme.onSecondaryContainer),
                    ),
                    title: Text(group, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
                    subtitle: Text('${subGroups.length} Sub-groups'),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => VerbSubGroupScreen(
                            groupName: group,
                            subGroups: subGroups,
                            allVerbs: _allVerbs,
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
  final List<String> subGroups;
  final List<VerbData> allVerbs;

  const VerbSubGroupScreen({
    super.key,
    required this.groupName,
    required this.subGroups,
    required this.allVerbs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(groupName)),
      body: ListView.builder(
        padding: EdgeInsets.only(
          left: 16.0, 
          right: 16.0, 
          top: 16.0, 
          bottom: MediaQuery.of(context).padding.bottom + 16.0, 
        ),
        itemCount: subGroups.length,
        itemBuilder: (context, index) {
          final subGroup = subGroups[index];
          final verbsInSubGroup = allVerbs.where((v) => v.group == groupName && v.subGroup == subGroup).toList();

          return Card(
            clipBehavior: Clip.antiAlias,
            elevation: 1.0,
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              leading: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(Icons.transform_rounded, color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),
              title: Text(subGroup, style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
              subtitle: Text('${verbsInSubGroup.length} Verbs'),
              trailing: const Icon(Icons.play_circle_fill_rounded, color: Colors.grey, size: 32.0),
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => VerbQuizScreen(
                      groupName: groupName,
                      subGroupName: subGroup,
                      verbList: verbsInSubGroup,
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