import 'package:flutter/material.dart';
import 'package:loyalty/core/dimensions.dart';
import 'package:loyalty/core/ui.dart';
import 'package:loyalty/features/models/loyalty_program_model.dart';
import 'package:loyalty/features/providers/customer_loyalty_card_provider.dart';
import 'package:loyalty/features/providers/loyalty_program_provider.dart';
import 'package:loyalty/features/providers/user_provider.dart';
import 'package:loyalty/features/screens/user/home/offer_detail.dart';
import 'package:provider/provider.dart';

class StampsPage extends StatefulWidget {
  const StampsPage({super.key});

  @override
  State<StampsPage> createState() => _StampsPageState();
}

class _StampsPageState extends State<StampsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshData());
  }

  Future<void> _refreshData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final loyaltyProgramProvider =
        Provider.of<LoyaltyProgramProvider>(context, listen: false);
    final customerLoyaltyCardProvider =
        Provider.of<CustomerLoyaltyCardProvider>(context, listen: false);

    if (userProvider.userId != null && userProvider.userId!.isNotEmpty) {
      await Future.wait([
        loyaltyProgramProvider.fetchIncompleteLoyaltyProgramsByCustomer(
          userProvider.userId!,
        ),
        loyaltyProgramProvider.fetchCollectedLoyaltyProgramsByCustomer(
          userProvider.userId!,
        ),
        customerLoyaltyCardProvider.fetchForCustomer(userProvider.userId!),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Vula',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: primaryColor,
        child: Consumer3<LoyaltyProgramProvider, CustomerLoyaltyCardProvider,
            UserProvider>(
          builder: (context, loyaltyProgramProvider, customerLoyaltyCardProvider,
              userProvider, _) {
            if (userProvider.userId == null || userProvider.userId!.isEmpty) {
              return _buildEmptyState(
                'Hyni për të parë vulat tuaja dhe shpërblimet e mbledhura',
              );
            }

            final incompletePrograms = loyaltyProgramProvider.loyaltyPrograms;
            final collectedPrograms =
                loyaltyProgramProvider.collectedLoyaltyPrograms;
            final isLoading = loyaltyProgramProvider.isLoading;
            final isLoadingCollected =
                loyaltyProgramProvider.isLoadingCollected;

            if (isLoading && incompletePrograms.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: primaryColor),
              );
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Incomplete loyalty programs (have stamps but not completed)
                    Text(
                      'Oferta të Papërfunduara',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (incompletePrograms.isEmpty)
                      _buildEmptySection('Asnjë program në progres')
                    else
                      ...incompletePrograms.map(
                        (program) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _StampCard(
                            loyaltyProgram: program,
                            currentStamps: program.currentStamps ??
                                customerLoyaltyCardProvider
                                    .getStampsForProgram(program.id),
                            isCollected: false,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    // Collected rewards
                    Text(
                      'Shpërblime të Mbledhura',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (isLoadingCollected && collectedPrograms.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        ),
                      )
                    else if (collectedPrograms.isEmpty)
                      _buildEmptySection('Asnjë shpërblim i mbledhur ende')
                    else
                      ...collectedPrograms.map(
                        (program) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _StampCard(
                            loyaltyProgram: program,
                            currentStamps: program.stampsRequired,
                            isCollected: true,
                            completedCycles: program.completedCycles ?? 1,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySection(String message) {
    return Container(
      width: getWidth(context),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(fontSize: 14, color: greyText),
        ),
      ),
    );
  }
}

class _StampCard extends StatelessWidget {
  final LoyaltyProgram loyaltyProgram;
  final int currentStamps;
  final bool isCollected;
  final int? completedCycles;

  const _StampCard({
    required this.loyaltyProgram,
    required this.currentStamps,
    required this.isCollected,
    this.completedCycles,
  });

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
      child: Opacity(
        opacity: isCollected ? 0.8 : 1,
        child: Container(
          width: getWidth(context),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: primaryColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  _buildImage(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loyaltyProgram.name,
                          style: TextStyle(
                            color: primaryTextColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${loyaltyProgram.price.toStringAsFixed(2)}€',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          loyaltyProgram.rewardDescription,
                          style: TextStyle(
                            fontSize: 12,
                            color: greyText,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                        if (isCollected && completedCycles != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Mbledhur ${completedCycles}x',
                              style: TextStyle(
                                fontSize: 12,
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(loyaltyProgram.stampsRequired, (index) {
                  final isFilled = index < currentStamps;
                  return Container(
                    height: 25,
                    width: 25,
                    margin: EdgeInsets.only(
                      right: loyaltyProgram.stampsRequired < 10 ? 8 : 4,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled ? primaryColor : Colors.grey[300],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final imageUrl = loyaltyProgram.firstImageUrl ?? loyaltyProgram.businessLogoUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: imageUrl != null && imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              height: 120,
              width: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 120,
      width: 120,
      color: Colors.grey[200],
      child: Icon(Icons.card_giftcard, size: 48, color: Colors.grey[500]),
    );
  }
}
