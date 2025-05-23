import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';
import 'package:lopako_app_lis/features/routines/models/routine_category_model.dart';
import 'package:lopako_app_lis/features/routines/models/routine_model.dart';
import 'package:lopako_app_lis/features/routines/screens/routine_detail_sheet.dart';
import 'package:lopako_app_lis/features/routines/widgets/routine_card_widget.dart';
import 'package:lopako_app_lis/features/routines/widgets/routine_category_chip_widget.dart';
import 'package:lopako_app_lis/generated/l10n.dart';

import '../controllers/routines_controller.dart';

class DiscoverRoutinesScreen extends StatefulWidget {
  const DiscoverRoutinesScreen({Key? key}) : super(key: key);

  @override
  _DiscoverRoutinesScreenState createState() => _DiscoverRoutinesScreenState();
}

class _DiscoverRoutinesScreenState extends State<DiscoverRoutinesScreen> {

  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  bool isSearching = false;
  bool isLoading = true;
  bool forceRefresh = false;

  List<RoutineCategory> categories = [];
  List<Routine> recommendedRoutines = [];
  List<Routine> filteredRoutines = [];

  RoutinesController routinesController = RoutinesController();
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isSearchActive = false;

  _DiscoverRoutinesScreenState();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshKey.currentState?.show();
    });
  }

  Future<void> _fetchCategories({bool forceRefresh = false}) async {
    final previouslySelected = categories
      .where((c) => c.isSelected).map((c) => c.id).toSet();
    try {
      final result = await routinesController.getCategories(
        forceRefresh: forceRefresh
      );
      categories = result.map((c) {
        c.isSelected = previouslySelected.contains(c.id);
        return c;
      }).toList();
    } catch (e) {
      setState(() {
        categories = [];
      });
      rethrow;
    }
  }

  Future<void> _fetchRecommendedRoutines({bool forceRefresh = false}) async {
    try {
      final result = await routinesController.getRecommendedRoutines(
        limit: 20,
        forceRefresh: forceRefresh
      );
      setState(() => recommendedRoutines = result);
    } catch (e) {
      setState(() {
        recommendedRoutines = [];
      });
      rethrow;
    }
  }

  Future<void> _fetchFilteredRoutines({bool forceRefresh = false}) async {
    setState(() {
      isSearching = true;
    });
    final search = _searchController.text;
    final categories = this.categories.where((category) => category.isSelected).toList();
    try {
      final result = await routinesController.getFilteredRoutines(
        search: search,
        categories: categories,
        limit: 20,
        forceRefresh: forceRefresh
      );
      setState(() => filteredRoutines = result);
    } catch (e) {
      setState(() {
        filteredRoutines = [];
      });
      rethrow;
    } finally {
      setState(() {
        isSearching = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      isLoading = true;
    });
    try {
      await _fetchCategories(forceRefresh: forceRefresh);
      if (isSearchActive) {
        await _fetchFilteredRoutines(forceRefresh: forceRefresh);
      } else {
        await _fetchRecommendedRoutines(forceRefresh: forceRefresh);
      }
      forceRefresh = true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          margin: const EdgeInsets.all(8),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showRoutineDetails(Routine routine) {
    showModalBottomSheet(
      elevation: 0,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RoutineDetailSheet(routine: routine),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);
    isSearchActive = _searchController.text.isNotEmpty || categories.any((category) => category.isSelected);
    final routines = isSearchActive ? filteredRoutines : recommendedRoutines;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.discoverRoutines),
      ),
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
              child: TextFormField(
                controller: _searchController,
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                decoration: InputDecoration(
                  labelText: localizations.search,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 22, color: AppColors.neutral),
                  ),
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 12,
                  ),
                ),
                onChanged: (value) async {
                  await _fetchFilteredRoutines();
                },
              )
            )
          ),
          Expanded(
            child: RefreshIndicator(
              key: _refreshKey,
              onRefresh: _refresh,
              color: AppColors.primary,
              backgroundColor: AppColors.neutral[50],
              displacement: 16,
              elevation: 0,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: isLoading
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 200),
                          if (!forceRefresh)
                            CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          const SizedBox(height: 16),
                          Text(localizations.loading),
                        ],
                      ),
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: categories.map((category) {
                              return RoutineCategoryChip(
                                label: category.label,
                                color: category.color,
                                selected: category.isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    category.isSelected = selected;
                                    _fetchFilteredRoutines();
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (!isSearchActive)
                          Text(
                            localizations.recommendedRoutines,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        isSearching
                          ? Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Center(
                              child: Text(
                                localizations.loading,
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                          : Column(
                            children: [
                              ...routines.map((routine) {
                                return Column(
                                  children: [
                                    const SizedBox(height: 12),
                                    RoutineCard(
                                      routine: routine,
                                      onSelected: (routine) {
                                        _showRoutineDetails(routine);
                                      },
                                    ),
                                  ],
                                );
                              }).toList(),
                              if (routines.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 64),
                                  child: Center(
                                    child: Text(
                                      localizations.noRoutinesFound,
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          )
                      ],
                    ),
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}
