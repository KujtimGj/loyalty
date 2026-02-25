import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loyalty/core/dimensions.dart';
import 'package:loyalty/core/ui.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/loyalty_program_provider.dart';
import '../../providers/business_user_provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/business_user_controller.dart';
import '../../../main.dart';
import 'signup_screen.dart';
import '../employee/staff_scanner_screen.dart';

class UnifiedLoginScreen extends StatefulWidget {
  const UnifiedLoginScreen({super.key});

  @override
  State<UnifiedLoginScreen> createState() => _UnifiedLoginScreenState();
}

class _UnifiedLoginScreenState extends State<UnifiedLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final businessUserProvider = Provider.of<BusinessUserProvider>(context, listen: false);
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    final loyaltyProgramProvider = Provider.of<LoyaltyProgramProvider>(context, listen: false);

    final customerResult = await AuthController.login(email: email, password: password);

    customerResult.fold((failure) async {
        // 2) Customer failed → try employee login
        final employeeResult = await BusinessUserController.login(email, password);

        employeeResult.fold(
          (empFailure) {
            if (mounted) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(empFailure.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          (businessUser) async {
            final businessResult = await BusinessUserController.getBusinessById(businessUser.businessId);
            businessResult.fold(
              (bFailure) {
                if (mounted) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to load business: ${bFailure.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              (business) {
                businessUserProvider.setBusinessUser(businessUser, business);
                if (mounted) {
                  setState(() => _isLoading = false);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => StaffScannerScreen(
                        business: business,
                        businessUserId: businessUser.id,
                        locationId: businessUser.locationId,
                      ),
                    ),
                    (route) => false,
                  );
                }
              },
            );
          },
        );
      },
      (authResponse) async {
        // Customer login success: set user and token via provider
        userProvider.setUser(authResponse.user, authResponse.token);
        try {
          await Future.wait([
            businessProvider.fetchAllBusinesses(),
            loyaltyProgramProvider.fetchAllLoyaltyPrograms(),
          ]);
        } catch (e) {
          print('Error loading initial data: $e');
        }
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Base()),
            (route) => false,
          );
        }
      },
    );
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    final loyaltyProgramProvider = Provider.of<LoyaltyProgramProvider>(context, listen: false);

    // Google Sign-In is only for customers, not employees
    final result = await userProvider.googleSignIn();

    result.fold(
      (failure) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      (user) async {
        // Load all required data before navigating
        try {
          await Future.wait([
            businessProvider.fetchAllBusinesses(),
            loyaltyProgramProvider.fetchAllLoyaltyPrograms(),
          ]);
        } catch (e) {
          print('Error loading initial data: $e');
        }
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Base()),
            (route) => false,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset("assets/wave.png"),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        'Hyrje',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hyni si klient ose staf',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text("Email"),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Shkruani email-in tuaj',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: secondBorderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: primaryColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: secondBorderColor),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ju lutemi shkruani email-in tuaj';
                          if (!value.contains('@')) return 'Ju lutemi shkruani një email të vlefshëm';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      Text("Fjalëkalimi"),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Shkruani fjalëkalimin tuaj',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: secondBorderColor,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: secondBorderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: secondBorderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: primaryColor),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ju lutemi shkruani fjalëkalimin tuaj';
                          if (value.length < 6) return 'Fjalëkalimi duhet të jetë të paktën 6 karaktere';
                          return null;
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text("Nuk keni llogari?", style: TextStyle(color: Colors.grey)),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignupScreen(),
                                ),
                              );
                            },
                            child: const Text('Regjistrohu', style: TextStyle(color: primaryColor)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: _isLoading ? null : _handleLogin,
                        child: Container(
                          width: getWidth(context),
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: _isLoading ? Colors.grey : primaryColor,
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text("Hyr", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(flex: 1,child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text("OR",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: greyText),),
                          ),
                          Expanded(flex: 1,child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: _isLoading ? null : _handleGoogleSignIn,
                        child: Container(
                          height: 55,
                          width: getWidth(context),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: borderColor),
                            borderRadius: BorderRadius.circular(10),
                            color: _isLoading ? Colors.grey[100] : Colors.transparent,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isLoading)
                                const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: primaryColor,
                                    strokeWidth: 2,
                                  ),
                                )
                              else ...[
                                SvgPicture.asset("assets/google.svg"),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text("Hyr me Google", style: TextStyle(fontSize: 16),),
                                )
                              ],
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
