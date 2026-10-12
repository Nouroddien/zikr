import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/responsive_content.dart';
import '../../l10n/app_localizations.dart';
import 'main_shell.dart';

class SebhaScreen extends StatefulWidget {
  const SebhaScreen({super.key});

  @override
  State<SebhaScreen> createState() => _SebhaScreenState();
}

class _SebhaScreenState extends State<SebhaScreen>
    with SingleTickerProviderStateMixin {
  static const _presets = [33, 99, 100];

  late final AnimationController _pulse;
  late final Animation<double> _scale;
  int _count = 0;
  int _target = 33;
  List<_SebhaSession> _history = [];

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(
      begin: 1,
      end: 0.965,
    ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeOut));
    _loadSavedState();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _loadSavedState() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedHistory = preferences.getString('sebhaHistory');
    final history = encodedHistory == null
        ? <_SebhaSession>[]
        : (jsonDecode(encodedHistory) as List<Object?>)
              .map(
                (entry) =>
                    _SebhaSession.fromJson(entry! as Map<String, Object?>),
              )
              .toList();
    if (!mounted) return;
    setState(() {
      _count = preferences.getInt('sebhaCount') ?? 0;
      _target = preferences.getInt('sebhaTarget') ?? 33;
      _history = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progress = min(_count / max(_target, 1), 1.0);
    return SafeArea(
      child: ResponsiveContent(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(top: 18, bottom: 24),
              sliver: SliverList.list(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.sebha,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.reset,
                        onPressed: _reset,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'سُبْحَانَ اللَّهِ',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Semantics(
                    button: true,
                    label: '${l10n.tapToCount}: $_count / $_target',
                    child: GestureDetector(
                      onTap: _increment,
                      child: Center(
                        child: ScaleTransition(
                          scale: _scale,
                          child: SizedBox(
                            width: min(
                              MediaQuery.sizeOf(context).width * 0.67,
                              285,
                            ),
                            height: min(
                              MediaQuery.sizeOf(context).width * 0.67,
                              285,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox.expand(
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 8,
                                    backgroundColor: AppColors.teal.withValues(
                                      alpha: 0.13,
                                    ),
                                    valueColor: const AlwaysStoppedAnimation(
                                      AppColors.gold,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  margin: const EdgeInsets.all(14),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [AppColors.ocean, AppColors.navy],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _count >= _target
                                            ? l10n.done
                                            : l10n.tapToCount,
                                        style: const TextStyle(
                                          color: AppColors.muted,
                                        ),
                                      ),
                                      Text(
                                        '$_count',
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 58,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        '${l10n.target}: $_target',
                                        style: const TextStyle(
                                          color: AppColors.gold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: [
                      for (final preset in _presets)
                        ChoiceChip(
                          label: Text('$preset'),
                          selected: _target == preset,
                          onSelected: (_) => _setTarget(preset),
                        ),
                      ChoiceChip(
                        label: Text(l10n.custom),
                        selected: !_presets.contains(_target),
                        onSelected: (_) => _customTarget(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.reset),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.vibration_outlined,
                        color: AppColors.teal,
                      ),
                      title: Text(l10n.done),
                      subtitle: Text(l10n.tapToCount),
                      trailing: const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.teal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppSectionTitle(l10n.sessionHistory),
                  const SizedBox(height: 8),
                  if (_history.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Text(
                          l10n.noSessions,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ),
                    )
                  else
                    for (final session in _history)
                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.check_circle,
                            color: AppColors.teal,
                          ),
                          title: Text('${l10n.target} ${session.target}'),
                          subtitle: Text(
                            DateFormat.yMMMd(
                              Localizations.localeOf(context).languageCode,
                            ).add_jm().format(session.completedAt),
                          ),
                          trailing: Text(
                            '${session.count}',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _increment() async {
    if (_count >= _target) return;
    _pulse.forward(from: 0).then((_) => _pulse.reverse());
    await HapticFeedback.selectionClick();
    final next = _count + 1;
    final preferences = await SharedPreferences.getInstance();
    if (next >= _target) {
      final session = _SebhaSession(
        count: next,
        target: _target,
        completedAt: DateTime.now(),
      );
      final history = [session, ..._history].take(20).toList();
      await preferences.setString(
        'sebhaHistory',
        jsonEncode(history.map((entry) => entry.toJson()).toList()),
      );
      await preferences.setInt('sebhaCount', next);
      await _targetReachedHaptics();
      if (!mounted) return;
      setState(() {
        _count = next;
        _history = history;
      });
    } else {
      await preferences.setInt('sebhaCount', next);
      if (!mounted) return;
      setState(() => _count = next);
    }
  }

  Future<void> _targetReachedHaptics() async {
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.selectionClick();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.vibrate();
  }

  Future<void> _setTarget(int value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt('sebhaTarget', value);
    if (!mounted) return;
    setState(() => _target = value);
  }

  Future<void> _customTarget() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final target = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.setCustomTarget),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l10n.enterNumber),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text.trim());
              if (value != null && value > 0 && value <= 100000) {
                Navigator.pop(context, value);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (target != null) await _setTarget(target);
  }

  Future<void> _reset() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt('sebhaCount', 0);
    if (mounted) setState(() => _count = 0);
  }
}

class _SebhaSession {
  const _SebhaSession({
    required this.count,
    required this.target,
    required this.completedAt,
  });

  final int count;
  final int target;
  final DateTime completedAt;

  Map<String, Object> toJson() => {
    'count': count,
    'target': target,
    'completedAt': completedAt.toIso8601String(),
  };

  factory _SebhaSession.fromJson(Map<String, Object?> json) {
    final count = json['count'];
    final target = json['target'];
    final completedAt = json['completedAt'];
    if (count is! int || target is! int || completedAt is! String) {
      throw const FormatException('Invalid saved Sebha session');
    }
    return _SebhaSession(
      count: count,
      target: target,
      completedAt: DateTime.parse(completedAt),
    );
  }
}
