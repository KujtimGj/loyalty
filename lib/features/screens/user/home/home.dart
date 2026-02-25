import 'package:flutter/material.dart';
import 'package:loyalty/core/dimensions.dart';
import 'package:loyalty/core/ui.dart';
import 'package:loyalty/features/screens/user/home/business_detail.dart';
import 'package:loyalty/features/screens/user/search.dart';
import 'package:loyalty/features/screens/user/secondary/category.dart';
import 'package:provider/provider.dart';
import '../../../providers/business_provider.dart';
import '../../../providers/loyalty_program_provider.dart';
import '../../../providers/customer_loyalty_card_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../models/loyalty_program_model.dart';
import '../../../controllers/loyalty_program_controller.dart';
import "package:flutter_svg/flutter_svg.dart";

import 'offer_detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

const _categories = [
  ("assets/categories/clothes.svg", "Clothes"),
  ("assets/categories/groceries.svg", "Groceries"),
  ("assets/categories/gas.svg", "Gas Stations"),
  ("assets/categories/food.svg", "Food"),
];

class _HomePageState extends State<HomePage> {
  List<LoyaltyProgram> _allLoyaltyPrograms = [];
  bool _isLoadingAllPrograms = false;

  Future<void> _refreshData() async {
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    final loyaltyProgramProvider = Provider.of<LoyaltyProgramProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final customerLoyaltyCardProvider =
        Provider.of<CustomerLoyaltyCardProvider>(context, listen: false);

    final futures = <Future<void>>[
      businessProvider.fetchAllBusinesses(),
    ];
    
    if (userProvider.userId != null && userProvider.userId!.isNotEmpty) {
      futures.add(
        loyaltyProgramProvider.fetchIncompleteLoyaltyProgramsByCustomer(userProvider.userId!),
      );
      futures.add(
        customerLoyaltyCardProvider.fetchForCustomer(userProvider.userId!),
      );
    } else {
      futures.add(
        loyaltyProgramProvider.fetchAllLoyaltyPrograms(),
      );
    }
    
    // Always fetch all programs for the Gastronomi section
    setState(() {
      _isLoadingAllPrograms = true;
    });
    futures.add(_fetchAllProgramsForGastronomi());
    
    await Future.wait(futures);
    setState(() {
      _isLoadingAllPrograms = false;
    });
  }

  Future<void> _fetchAllProgramsForGastronomi() async {
    final result = await LoyaltyProgramController.fetchAllLoyaltyPrograms();
    result.fold(
      (failure) {
        setState(() {
          _allLoyaltyPrograms = [];
        });
      },
      (programs) {
        setState(() {
          _allLoyaltyPrograms = programs;
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text(
          "Përshëndetje",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color(0xff363636),
          ),
        ),
        toolbarHeight: 80,
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => SearchModal(),
              );
            },
            icon: Icon(Icons.search, size: 30),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.filter_alt_outlined, size: 30),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: primaryColor,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Ofertat Aktive",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: primaryTextColor,
                        ),
                      ),
                       GestureDetector(
                         onTap: (){
                           Navigator.push(context, MaterialPageRoute(builder: (_)=>Category()));
                         },
                         child: Text(
                          "Shiko të gjitha",
                          style: TextStyle(fontSize: 15, color: greyText),
                                               ),
                       ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Consumer2<LoyaltyProgramProvider, CustomerLoyaltyCardProvider>(
                  builder: (context, loyaltyProgramProvider, customerLoyaltyCardProvider, child,) {
                    if (loyaltyProgramProvider.isLoading) {
                      return SizedBox(
                        height: 300,
                        child: Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        ),
                      );
                    }

                    if (loyaltyProgramProvider.hasError) {
                      return SizedBox(
                        height: 300,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Gabim në ngarkimin e programeve të besnikërisë',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                                  if (userProvider.userId != null && userProvider.userId!.isNotEmpty) {
                                    loyaltyProgramProvider
                                        .fetchIncompleteLoyaltyProgramsByCustomer(userProvider.userId!);
                                  } else {
                                    loyaltyProgramProvider
                                        .fetchAllLoyaltyPrograms();
                                  }
                                },
                                child: Text('Provo Përsëri'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final programs = loyaltyProgramProvider.loyaltyPrograms;

                    if (programs.isEmpty) {
                      return SizedBox(
                        height: 300,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.card_giftcard_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Asnjë program besnikërie i disponueshëm',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SizedBox(
                      height: 300,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: programs.length,
                          itemBuilder: (context, index) {
                            final program = programs[index];
                            final currentStamps = program.currentStamps ?? 
                                customerLoyaltyCardProvider.getStampsForProgram(program.id);
                            return _BusinessCard(
                              loyaltyProgram: program,
                              currentStamps: currentStamps,
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Gastronomi",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: primaryTextColor,
                        ),
                      ),
                      Text(
                        "Shiko të gjitha",
                        style: TextStyle(fontSize: 15, color: greyText),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Consumer<CustomerLoyaltyCardProvider>(
                  builder: (context, customerLoyaltyCardProvider, child) {
                    if (_isLoadingAllPrograms) {
                      return SizedBox(
                        height: 300,
                        child: Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        ),
                      );
                    }

                    // Filter programs by industry 'Gastronomi' from all programs
                    final gastronomiPrograms = _allLoyaltyPrograms
                        .where((program) => program.businessIndustry == 'Gastronomi')
                        .toList();

                    if (gastronomiPrograms.isEmpty) {
                      return SizedBox(
                        height: 300,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Asnjë program Gastronomi i disponueshëm',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SizedBox(
                      height: 300,
                      width: getWidth(context),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: gastronomiPrograms.length,
                          itemBuilder: (context, index) {
                            final program = gastronomiPrograms[index];
                            final currentStamps = program.currentStamps ??
                                customerLoyaltyCardProvider.getStampsForProgram(program.id);
                            return _BusinessCard(
                              loyaltyProgram: program,
                              currentStamps: currentStamps,
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Dyqane",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: primaryTextColor,
                        ),
                      ),
                      Text(
                        "Shiko të gjitha",
                        style: TextStyle(fontSize: 15, color: greyText),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Consumer<BusinessProvider>(
                  builder: (context, businessProvider, child) {
                    if (businessProvider.isLoading) {
                      return SizedBox(
                        height: 100,
                        width: getWidth(context),
                        child: Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        ),
                      );
                    }

                    if (businessProvider.hasError) {
                      return SizedBox(
                        height: 100,
                        width: getWidth(context),
                        child: Center(
                          child: Text(
                            'Gabim në ngarkimin e bizneseve',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      );
                    }

                    if (businessProvider.businesses.isEmpty) {
                      return SizedBox(
                        height: 100,
                        width: getWidth(context),
                        child: Center(
                          child: Text(
                            'Asnjë biznes i gjetur',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      );
                    }

                    return SizedBox(
                      height: 100,
                      width: getWidth(context),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: businessProvider.businesses.length,
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final business = businessProvider.businesses[index];
                            return GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (_)=>BusinessDetailPage(business: business)));
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 80,
                                    width: 80,
                                    margin: EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[200],
                                      image:
                                          business.logoUrl != null &&
                                                  business.logoUrl!.isNotEmpty
                                              ? DecorationImage(
                                                image: NetworkImage(
                                                  business.logoUrl!,
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                              : null,
                                    ),
                                    child:
                                        business.logoUrl == null ||
                                                business.logoUrl!.isEmpty
                                            ? Icon(
                                              Icons.store,
                                              size: 40,
                                              color: Colors.grey[600],
                                            )
                                            : null,
                                  ),
                                  Text(business.name),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BusinessCard extends StatelessWidget {
  final LoyaltyProgram loyaltyProgram;
  final int currentStamps;

  const _BusinessCard({required this.loyaltyProgram, this.currentStamps = 0});

  double _calculateStampSize(BuildContext context, int stampCount) {
    final cardWidth = getWidth(context) * 0.65;
    final padding = 16.0; // 8px on each side
    final textWidth = 80.0; // Approximate width for "X vula" text
    final availableWidth = cardWidth - padding - textWidth;
    
    // Calculate spacing: 5px for <10 stamps, 2px for >=10 stamps
    final spacing = stampCount < 10 ? 5.0 : 2.0;
    final totalSpacing = spacing * (stampCount - 1);
    final availableForStamps = availableWidth - totalSpacing;
    
    // Calculate size per stamp
    double calculatedSize = availableForStamps / stampCount;
    
    // Clamp between minimum (18) and maximum (25)
    return calculatedSize.clamp(18.0, 25.0);
  }

  List<Widget> _buildRewardButton() {
    if (currentStamps >= loyaltyProgram.stampsRequired) {
      return [
        SizedBox(height: 10),
        Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: primaryColor,
          ),
          child: Center(
            child: Text(
              "Merr Shpërblimin",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OfferDetail(loyaltyProgram: loyaltyProgram),
          ),
        );
      },
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          width: getWidth(context) * 0.65,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: primaryColor),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(8),
          margin: EdgeInsets.only(right: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            SizedBox(
              height: 120,
              width: getWidth(context),
              child:
                  loyaltyProgram.firstImageUrl != null
                      ? Image.network(
                        loyaltyProgram.firstImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.image_not_supported, size: 48),
                          );
                        },
                      )
                      : Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.card_giftcard, size: 48),
                      ),
            ),
            SizedBox(height: 8),
            Text(
              loyaltyProgram.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              loyaltyProgram.businessName ?? 'Biznes',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 10),
            Builder(
              builder: (context) {
                final stampSize = _calculateStampSize(context, loyaltyProgram.stampsRequired);
                final spacing = loyaltyProgram.stampsRequired < 10 ? 5.0 : 2.0;
                
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ...List.generate(loyaltyProgram.stampsRequired, (index) {
                      final isFilled = index < currentStamps;
                      return Container(
                        margin: EdgeInsets.only( 
                          right: spacing,
                        ),
                        height: stampSize,
                        width: stampSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFilled ? primaryColor : Colors.grey[300],
                        ),
                      );
                    }),
                    Text(
                      "${loyaltyProgram.stampsRequired} vula",
                      style: TextStyle(fontSize: 12, color: greyText),
                    ),
                  ],
                );
              },
            ),
            ..._buildRewardButton(),
          ],
        ),
        ),
      ),
    );
  }
}
