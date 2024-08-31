import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:project2/temp_constant.dart';
import 'package:shimmer/shimmer.dart';
import 'Features/Attendance/Models/unite_enseignement.dart';
import 'Features/Attendance/Models/school_year.dart';
import 'Features/Attendance/Screens/scanner_handling.dart';
import 'Features/Attendance/Screens/school_year_dialog.dart';
import 'Features/Attendance/Services/synchronisation.dart';
import 'db_init.dart';
import 'drawer.dart';
import 'error_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<UniteEnseignement> uniteEnseignements = [];
  List<SchoolYear> schoolYears = [];
  String? selectedPromotion;
  ElementConst? selectedElement;
  SchoolYear? selectedYear;
  bool isLoadingElements = false;
  bool isLoadingYears = true;
  DatabaseConfig db = DatabaseConfig.instance;

  SchoolYear? currentSchoolYear;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchUniteEnseignements();
    _fetchSchoolYears();
  }

  void _openSchoolYearDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SchoolYearDialog(
          onSave: (int startYear, int endYear) async {
            await DatabaseConfig.instance.insertSchoolyear(startYear, endYear);
            _fetchSchoolYears();
          },
        );
      },
    );
  }

  Future<void> _fetchUniteEnseignements() async {
    try {
      List<UniteEnseignement> fetchedUniteEnseignements =
          await DatabaseConfig.instance.getAllUniteEnseignements();
      setState(() {
        uniteEnseignements = fetchedUniteEnseignements;
      });
    } catch (e) {
      debugPrint('Error fetching unite enseignements: $e');
    }
  }

  Future<void> _startSynchronization() async {
    try {
      String currentApi = await db.getApiUrl();

      // Start the synchronization process
      await Synchronisation().syncUE(currentApi);

      // Only navigate if the widget is still mounted
      if (!mounted) return;

      // If successful, navigate to the home page
      Navigator.pushReplacementNamed(context, '/home');
    } catch (error) {
      // Only navigate if the widget is still mounted
      if (!mounted) return;

      // If synchronization fails, navigate to the error page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SyncErrorPage(),
        ),
      );
    }
  }

  Future<List<ElementConst>> _getElementsAsync(String promotion) async {
    setState(() {
      isLoadingElements = true;
    });

    var splitPromotion = promotion.split(' - ');
    String filiare = splitPromotion[0];
    int level = int.parse(splitPromotion[1].replaceAll('Level ', ''));

    var elementsList = uniteEnseignements
        .where((ue) => ue.filiare == filiare && ue.level == level)
        .expand((ue) => ue.elementConstituf)
        .toList();

    setState(() {
      isLoadingElements = false;
    });

    return elementsList;
  }

  List<String> _extractPromotions(List<UniteEnseignement> data) {
    Set<String> promotionSet =
        data.map((ue) => '${ue.filiare} - Level ${ue.level}').toSet();
    return promotionSet.toList();
  }

  List<String> _formatSchoolYears(List<SchoolYear> schoolYears) {
    return schoolYears
        .map((year) => '${year.startYear}-${year.endYear}')
        .toList();
  }

  Future<void> _fetchSchoolYears() async {
    try {
      List<SchoolYear> fetchedSchoolYears =
          await DatabaseConfig.instance.getAllSchoolYears();
      setState(() {
        schoolYears = fetchedSchoolYears;
        isLoadingYears = false;
        _setCurrentSchoolYear();
      });
    } catch (e) {
      debugPrint('Error fetching school years: $e');
      setState(() {
        isLoadingYears = false;
      });
    }
  }

  void _setCurrentSchoolYear() {
    if (schoolYears.isNotEmpty) {
      schoolYears.sort((a, b) => b.endYear.compareTo(a.endYear));
      currentSchoolYear = schoolYears.first;
      selectedYear = currentSchoolYear; // Set default selected year
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Center(
          child: Text(
            'ATT - TOOL',
            style: TextStyle(
              letterSpacing: 4.0,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh_outlined),
              tooltip: 'Sync Unité enseignement',
              onPressed: () {
                //Start synchronisation
                _startSynchronization();
                print("syncing");
              })
        ],
        elevation: 0,
        backgroundColor: Colors.grey,
        foregroundColor: Colors.white,
      ),
      drawer: const Menu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: uniteEnseignements.isEmpty &&
                schoolYears.isEmpty &&
                !isLoadingYears
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Center(
                      child: Text(
                        'Aucune anne scolaire trouvée',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _openSchoolYearDialog,
                      style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all<Color>(Colors.blue)),
                      child: const Text('Ajouter une Année'),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCard(
                          title: 'Sélectionnez une Promotion',
                          child: DropdownSearch<String>(
                            items: _extractPromotions(uniteEnseignements),
                            selectedItem: selectedPromotion,
                            filterFn: (item, filter) => item
                                .toLowerCase()
                                .contains(filter.toLowerCase()),
                            onChanged: (String? value) {
                              setState(() {
                                selectedPromotion = value;
                                selectedElement =
                                    null; // Reset selected element when promotion changes
                              });
                            },
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                labelText: "Sélectionnez une Promotion",
                                contentPadding:
                                    const EdgeInsets.fromLTRB(12, 12, 0, 0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildCard(
                          title: 'Sélectionnez un Élément Constitutif',
                          child: isLoadingElements
                              ? _buildShimmerEffect()
                              : DropdownSearch<ElementConst>(
                                  asyncItems: (String filter) =>
                                      _getElementsAsync(selectedPromotion!),
                                  itemAsString: (ElementConst ec) => ec.name,
                                  filterFn: (item, filter) => item.name
                                      .toLowerCase()
                                      .contains(filter.toLowerCase()),
                                  onChanged: (ElementConst? data) {
                                    setState(() {
                                      selectedElement = data;
                                    });
                                  },
                                  dropdownDecoratorProps:
                                      DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(
                                      labelText:
                                          "Sélectionnez un Élément Constitutif",
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          12, 12, 0, 0),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Années Scolaires',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.blueAccent),
                        ),
                        const SizedBox(height: 16),
                        isLoadingYears
                            ? _buildShimmerEffect()
                            : schoolYears.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Center(
                                          child: Text(
                                            'Aucune anne scolaire trouvée',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: _openSchoolYearDialog,
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStateProperty.all<
                                                      Color>(Colors.blue)),
                                          child:
                                              const Text('Ajouter une Année'),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    children: [
                                      SizedBox(
                                        height: 100,
                                        child: PageView.builder(
                                          itemCount: schoolYears.length,
                                          onPageChanged: (int index) {
                                            setState(() {
                                              currentIndex = index;
                                              selectedYear = schoolYears[index];
                                            });
                                          },
                                          itemBuilder: (context, index) {
                                            final year = schoolYears[index];
                                            final isCurrentYear =
                                                year == currentSchoolYear;
                                            return _buildYearCard(
                                              year: year,
                                              isCurrentYear: isCurrentYear,
                                              isSelected: currentIndex == index,
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(
                                          schoolYears.length,
                                          (index) => AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 4),
                                            width:
                                                currentIndex == index ? 12 : 8,
                                            height:
                                                currentIndex == index ? 12 : 8,
                                            decoration: BoxDecoration(
                                              color: currentIndex == index
                                                  ? Colors.blueAccent
                                                  : Colors.grey,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      IconButton(
                                        onPressed: _openSchoolYearDialog,
                                        icon: const Icon(
                                            Icons.add_circle_outline),
                                        iconSize: 50,
                                        color: Colors.blueGrey,
                                      )
                                    ],
                                  ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: ValidateAndProceedButton(
        selectedPromotion: selectedPromotion,
        selectedElement: selectedElement,
        selectedYear: selectedYear,
        isFloatingActionButton: true, // Set to true for FloatingActionButton
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 50,
        color: Colors.white,
      ),
    );
  }

  Widget _buildYearCard(
      {required SchoolYear year,
      required bool isCurrentYear,
      required bool isSelected}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: isSelected ? Colors.blueAccent : Colors.transparent,
            width: 2),
      ),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: isCurrentYear
              ? const LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlueAccent])
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${year.startYear} - ${year.endYear}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isCurrentYear
                    ? Colors.white
                    : Colors.black87, // Set color based on `isCurrentYear`
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
