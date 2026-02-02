import 'package:flutter/material.dart';
import 'package:loyalty/core/ui.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_core/firebase_core.dart';

import 'features/screens/user/home.dart';
import 'features/screens/user/profile.dart';
import 'features/screens/user/qrcode.dart';
import 'features/screens/user/stamps.dart';
import 'features/screens/auth/welcome_screen.dart';
import 'features/screens/employee/staff_scanner_screen.dart';
import 'features/providers/business_provider.dart';
import 'features/providers/user_provider.dart';
import 'features/providers/business_user_provider.dart';
import 'features/providers/loyalty_program_provider.dart';
import 'features/providers/customer_loyalty_card_provider.dart';
import 'features/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize notification service
  await NotificationService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});         

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider( 
          create: (_) {
            return BusinessProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return UserProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return BusinessUserProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return LoyaltyProgramProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            return CustomerLoyaltyCardProvider();
          },
        ),
      ],
      child: MaterialApp(
        color: Colors.white,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: AppBarTheme(backgroundColor: Colors.white),
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, BusinessUserProvider>(
      builder: (context, userProvider, businessUserProvider, child) {
        // Check if customer is logged in
        if (userProvider.isLoggedIn) {
          return const Base();
        }

        // Check if business user is logged in
        if (businessUserProvider.isLoggedIn &&
            businessUserProvider.currentBusiness != null) {
          return StaffScannerScreen(
            business: businessUserProvider.currentBusiness!,
            businessUserId: businessUserProvider.currentBusinessUser!.id,
            locationId: businessUserProvider.currentBusinessUser!.locationId,
          );
        }

        // Show welcome screen if no one is logged in
        return const WelcomeScreen();
      },
    );
  }
}

class Base extends StatefulWidget {
  const Base({super.key});

  @override
  State<Base> createState() => _BaseState();
}

class _BaseState extends State<Base> {
  int _currentIndex = 0;
  bool _isInitialDataLoaded = false;

  final List<Widget> _pages = [
    HomePage(),
    StampsPage(),
    QRCodePage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // Defer data load until after build completes to avoid setState/markNeedsBuild during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    final loyaltyProgramProvider = Provider.of<LoyaltyProgramProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final customerLoyaltyCardProvider = Provider.of<CustomerLoyaltyCardProvider>(context, listen: false);

    // Load data if not already loaded
    if (businessProvider.businesses.isEmpty || loyaltyProgramProvider.loyaltyPrograms.isEmpty) {
      await Future.wait([
        businessProvider.fetchAllBusinesses(),
        loyaltyProgramProvider.fetchAllLoyaltyPrograms(),
      ]);
    }

    // Load customer loyalty cards (for stamp display) when user is logged in
    if (userProvider.userId != null && userProvider.userId!.isNotEmpty) {
      await customerLoyaltyCardProvider.fetchForCustomer(userProvider.userId!);
    }

    if (mounted) {
      setState(() {
        _isInitialDataLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen until initial data is loaded
    if (!_isInitialDataLoaded) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedLabelStyle: TextStyle(color: primaryColor),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/nav/home.svg",width: 30,height: 30,),
            activeIcon: SvgPicture.asset(
              "assets/nav/home.svg",
              colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
              width: 30,height: 30,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/nav/shopping-bag.svg",width: 30,height: 30,),
            activeIcon: SvgPicture.asset(
              "assets/nav/shopping-bag.svg",
              colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
              width: 30,height: 30,
            ),
            label: 'Stamps',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/nav/grid.svg",width: 30,height: 30,),
            activeIcon: SvgPicture.asset(
              "assets/nav/grid.svg",
              colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
              width: 30,height: 30,
            ),
            label: 'QR Code',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/nav/user.svg",width: 30,height: 30,),
            activeIcon: SvgPicture.asset(
              "assets/nav/user.svg",
              colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
              width: 30,height: 30,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
