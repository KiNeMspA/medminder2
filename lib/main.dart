import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'common/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/medication/screens/medication_info_screen.dart';
import 'features/medication/screens/medication_add_screen.dart';
import 'features/medication/screens/medication_edit_screen.dart';
import 'features/dose/screens/dose_info_screen.dart';
import 'features/dose/screens/dose_add_screen.dart';
import 'features/dose/screens/dose_edit_screen.dart';
import 'features/schedule/screens/schedule_info_screen.dart';
import 'features/schedule/screens/schedule_add_screen.dart';
import 'features/schedule/screens/schedule_edit_screen.dart';
import 'services/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedMinder',
      theme: appTheme,
      navigatorKey: navigatorKey,
      home: const MainScaffold(),
      routes: {
        '/medications/info': (context) => const MedicationsInfoScreen(),
        '/medications/add': (context) => const MedicationsAddScreen(),
        '/medications/edit': (context) => MedicationsEditScreen(
          medicationId: ModalRoute.of(context)!.settings.arguments as int,
        ),
        '/doses/info': (context) => const DosesInfoScreen(),
        '/doses/add': (context) => const DosesAddScreen(),
        '/doses/edit': (context) => DosesEditScreen(
          doseId: ModalRoute.of(context)!.settings.arguments as int,
        ),
        '/schedules/info': (context) => const SchedulesInfoScreen(),
        '/schedules/add': (context) => const SchedulesAddScreen(),
        '/schedules/edit': (context) => SchedulesEditScreen(
          scheduleId: ModalRoute.of(context)!.settings.arguments as int,
        ),
      },
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    MedicationsInfoScreen(),
    DosesInfoScreen(),
    SchedulesInfoScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.medication), label: 'Medications'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Doses'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Schedules'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}