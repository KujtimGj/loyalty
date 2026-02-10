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
      loyaltyProgramProvider.fetchAllLoyaltyPrograms(),
    ];
    if (userProvider.userId != null && userProvider.userId!.isNotEmpty) {
      futures.add(
        customerLoyaltyCardProvider.fetchForCustomer(userProvider.userId!),
      );
    }
    await Future.wait(futures);
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
          "Hello Drin",
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Search()),
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
                        "Active Offers",
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
                          "View All",
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
                                'Error loading loyalty programs',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  loyaltyProgramProvider
                                      .fetchAllLoyaltyPrograms();
                                },
                                child: Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final programs =
                        loyaltyProgramProvider.getActiveLoyaltyPrograms();

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
                                'No loyalty programs available',
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
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: programs.length,
                        itemBuilder: (context, index) {
                          final program = programs[index];
                          final currentStamps = customerLoyaltyCardProvider
                              .getStampsForProgram(program.id);
                          return _BusinessCard(
                            loyaltyProgram: program,
                            currentStamps: currentStamps,
                          );
                        },
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Food & Coffee",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: primaryTextColor,
                        ),
                      ),
                      Text(
                        "View All",
                        style: TextStyle(fontSize: 15, color: greyText),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 270,
                  width: getWidth(context),
                  child: ListView.builder(
                    physics: ClampingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.only(right: 10),
                        width: 300,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: primaryColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(child: Image.asset("assets/kfc2.png",height: 150,)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Sach Attack",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          " 5,99€",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text("Sach Pizza"),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Reward",style: TextStyle(fontSize: 10,)),
                                    Text("Free Meal",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600),)
                                  ],
                                )
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...List.generate(8, (_) => Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: unfilledStamp
                                    ),
                                  ),
                                )),
                                Text("8 vula"),
                              ],
                            )
                          ], 
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Stores",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: primaryTextColor,
                        ),
                      ),
                      Text(
                        "View All",
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
                            'Error loading businesses',
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
                            'No businesses found',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      );
                    }

                    return SizedBox(
                      height: 100,
                      width: getWidth(context),
                      child: ListView.builder(
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
      child: Container(
        width: getWidth(context) * 0.65,
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: primaryColor),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(10),
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
              loyaltyProgram.businessName ?? 'Business',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(loyaltyProgram.stampsRequired, (index) {
                final isFilled = index < currentStamps;
                return Container(
                  margin: EdgeInsets.only(
                    right: loyaltyProgram.stampsRequired < 10 ? 5 : 1,
                  ),
                  height: loyaltyProgram.stampsRequired < 10 ? 25 : 20,
                  width: loyaltyProgram.stampsRequired < 10 ? 25 : 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled ? primaryColor : Colors.grey[300],
                    border:
                        isFilled
                            ? null
                            : Border.all(
                              color: primaryColor.withOpacity(0.5),
                              width: 1.5,
                            ),
                  ),
                );
              }),
            ),
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
                  "Collect Reward",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
