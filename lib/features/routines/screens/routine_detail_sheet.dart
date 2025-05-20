import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';
import 'package:lopako_app_lis/core/widgets/icon_3d.dart';
import 'package:lopako_app_lis/features/family_circles/controllers/family_circles_controller.dart';
import 'package:lopako_app_lis/features/routines/models/routine_activity_model.dart';
import 'package:lopako_app_lis/features/routines/models/routine_model.dart';
import 'package:lopako_app_lis/features/routines/widgets/routine_activity_card_widget.dart';
import 'package:lopako_app_lis/features/routines/widgets/routine_category_score_widget.dart';
import 'package:lopako_app_lis/generated/l10n.dart';

class RoutineDetailSheet extends StatefulWidget {
  final Routine routine;
  const RoutineDetailSheet({Key? key, required this.routine}) : super(key: key);

  @override
  _RoutineDetailSheetState createState() => _RoutineDetailSheetState();
}

class _RoutineDetailSheetState extends State<RoutineDetailSheet> with SingleTickerProviderStateMixin {

  final FamilyCirclesController _familyCirclesController = FamilyCirclesController();
  
  final _scrollCtrl = ScrollController();

  bool _formCollapsed = true;
  bool _isFormDisabled = false;
  late final AnimationController _formCtrl;
  late final Animation<Offset> _slideForm;
  final Duration _slideAnimationTime = const Duration(milliseconds: 150);

  String _selectedDateOption = 'today';
  String _selectedPeriodOption = 'morning';

  @override
  void initState() {
    super.initState();
    _formCtrl = AnimationController(vsync: this, duration: _slideAnimationTime);
    _slideForm = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _formCtrl, curve: Curves.easeOut));
    _selectedPeriodOption = _getAvailablePeriodsForToday().first;
  }

  void _toggleForm() {
    if (_formCollapsed) {
      _formCtrl.forward();
    } else {
      _formCtrl.reverse();
    }
    setState(() => _formCollapsed = !_formCollapsed);
  }

  List<String> _getAvailablePeriodsForToday() {
    final now = TimeOfDay.now();
    final periods = <String>[];
    if (now.hour < 12) periods.add('morning');
    if (now.hour < 18) periods.add('afternoon');
    periods.add('night');
    return periods;
  }

  String _labelForPeriod(String key) {
    switch (key) {
      case 'morning':
        return S.of(context).morning;
      case 'afternoon':
        return S.of(context).afternoon;
      case 'night':
        return S.of(context).night;
      default:
        return key;
    }
  }
  
  Future<void> scheduleRoutine() async {
    setState(() {
      _isFormDisabled = true;
    });
    try {
      await _familyCirclesController.addRoutine(
        widget.routine,
        day: _selectedDateOption,
        period: _selectedPeriodOption,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          margin: const EdgeInsets.all(8),
        ),
      );
    } finally {
      setState(() {
        _isFormDisabled = false;
      });
    }
    Navigator.of(context).pop();
  }

  Future<void> startRoutine() async {
    setState(() {
      _isFormDisabled = true;
    });
    try {
      await _familyCirclesController.startRoutine(widget.routine);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          margin: const EdgeInsets.all(8),
        ),
      );
    } finally {
      setState(() {
        _isFormDisabled = false;
      });
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void dispose() {
    _formCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);
    final formButtonFullWidth = MediaQuery.of(context).size.width - 32;

    final height = MediaQuery.of(context).size.height * 0.85;
    final routine = widget.routine;

    final microlearningActivities =
        routine.activities
            .where(
              (activity) => activity.type == RoutineActivityType.microlearning,
            )
            .toList();
    final practiceActivities =
        routine.activities
            .where((activity) => activity.type == RoutineActivityType.practice)
            .toList();

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(),
                  clipBehavior: Clip.antiAlias,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is OverscrollNotification &&
                          notification.overscroll < -12) {
                        Navigator.of(context).pop();
                        return true;
                      }
                      return false;
                    },
                    child: SingleChildScrollView(
                      controller: _scrollCtrl,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                child: Icon3d(routine.icon, size: 80),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: routine.category.color[50]!
                                          .withAlpha(191),
                                      blurRadius: 1000,
                                      spreadRadius: 500,
                                    ),
                                    BoxShadow(
                                      color: routine.category.color.withAlpha(
                                        128,
                                      ),
                                      blurRadius: 128,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    top: 12,
                                    bottom: 16,
                                  ),
                                  child: Text(
                                    routine.title,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.solidClock,
                                  size: 12,
                                  color: AppColors.neutral,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  routine.duration,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.neutral,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                FaIcon(
                                  FontAwesomeIcons.solidCalendarDays,
                                  size: 12,
                                  color: AppColors.neutral,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  routine.schedule,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.neutral,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            routine.description,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            color: routine.category.color[50],
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  RoutineCategoryScore(
                                    category: routine.category,
                                    selected: true,
                                  ),
                                  ...routine.subcategories.map(
                                    (subcategory) => Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: RoutineCategoryScore(
                                        category: subcategory,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Center(
                            child: Text(
                              localizations.routineCategoriesScoresHelpText,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.neutral[400],
                              ),
                            ),
                          ),
                          if (microlearningActivities.isNotEmpty) ...[
                            const SizedBox(height: 32),
                            Text(
                              localizations.whatYouWillLearn,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            ...microlearningActivities.map(
                              (activity) => Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: RoutineActivityCard(activity: activity),
                              ),
                            ),
                          ],
                          if (practiceActivities.isNotEmpty) ...[
                            const SizedBox(height: 32),
                            Text(
                              localizations.whatWillWeDo,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            ...practiceActivities.map(
                              (activity) => Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: RoutineActivityCard(activity: activity),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(height: 2, color: AppColors.neutral[200]),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(),
                      child: Row(
                        children: [
                          Expanded(
                            child: AbsorbPointer(
                              absorbing: _isFormDisabled,
                              child: SlideTransition(
                                position: _slideForm,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedDateOption,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12
                                          ),
                                        ),
                                        items: [
                                          DropdownMenuItem(
                                            value: 'today',
                                            child: Text(localizations.today),
                                          ),
                                          DropdownMenuItem(
                                            value: 'tomorrow',
                                            child: Text(localizations.tomorrow),
                                          ),
                                        ],
                                        onChanged: (v) {
                                          if (v == null) return;
                                          setState(() {
                                            _selectedDateOption = v;
                                            if (v == 'today') {
                                              final avail = _getAvailablePeriodsForToday();
                                              if (!avail.contains(_selectedPeriodOption)) {
                                                _selectedPeriodOption = avail.first;
                                              }
                                            } else {
                                              _selectedPeriodOption = 'morning';
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedPeriodOption,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                        ),
                                        items: (_selectedDateOption == 'today'
                                            ? _getAvailablePeriodsForToday()
                                            : ['morning', 'afternoon', 'night'])
                                            .map((opt) => DropdownMenuItem(
                                          value: opt,
                                          child: Text(_labelForPeriod(opt)),
                                        ))
                                            .toList(),
                                        onChanged: (v) {
                                          if (v != null) {
                                            setState(() => _selectedPeriodOption = v);
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          TweenAnimationBuilder<Color?>(
                            tween: ColorTween(
                              begin:
                                _formCollapsed
                                  ? AppColors.primary[50]
                                  : AppColors.primary,
                              end:
                                _formCollapsed
                                  ? AppColors.primary[50]
                                  : AppColors.primary,
                            ),
                            duration: _slideAnimationTime,
                            builder: (context, bgColor, child) {
                              return AnimatedContainer(
                                duration: _slideAnimationTime,
                                curve: Curves.easeOut,
                                width: _formCollapsed ? formButtonFullWidth : 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: child,
                              );
                            },
                            child: TextButton(
                              style: TextButton.styleFrom(
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                                padding: EdgeInsets.zero,
                                backgroundColor: Colors.transparent,
                                foregroundColor:
                                  _formCollapsed
                                    ? AppColors.primary[700]
                                    : Colors.white,
                              ),
                              onPressed: _isFormDisabled ? null : _toggleForm,
                              child: AnimatedSwitcher(
                                duration: _slideAnimationTime,
                                transitionBuilder:
                                  (child, anim) => FadeTransition(
                                    opacity: anim,
                                    child: child,
                                  ),
                                child: Row(
                                  key: ValueKey(_formCollapsed),
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FaIcon(FontAwesomeIcons.solidClock),
                                    if (_formCollapsed)
                                      const SizedBox(width: 8),
                                    if (_formCollapsed)
                                      Text(S.of(context).later, maxLines: 1),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      child: AnimatedSwitcher(
                        duration: _slideAnimationTime,
                        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                        child: Text(_formCollapsed
                          ? S.of(context).startNow
                          : S.of(context).later,
                          key: ValueKey(_formCollapsed),
                        ),
                      ),
                      onPressed: _isFormDisabled
                        ? null
                        : _formCollapsed
                          ? startRoutine
                          : scheduleRoutine,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
