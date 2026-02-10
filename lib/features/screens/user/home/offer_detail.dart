import 'package:flutter/material.dart';
import 'package:loyalty/core/dimensions.dart';
import 'package:loyalty/core/ui.dart';
import 'package:loyalty/features/components/components.dart';
import 'package:provider/provider.dart';
import '../../../models/loyalty_program_model.dart';
import '../../../providers/customer_loyalty_card_provider.dart';
import '../../../providers/loyalty_program_provider.dart';

class OfferDetail extends StatefulWidget {
  final LoyaltyProgram loyaltyProgram;

  const OfferDetail({super.key, required this.loyaltyProgram});

  @override
  State<OfferDetail> createState() => _OfferDetailState();
}

class _OfferDetailState extends State<OfferDetail> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<LoyaltyProgramProvider>()
          .fetchActiveLoyaltyProgramsByBusiness(
            widget.loyaltyProgram.businessId,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final loyaltyProgram = widget.loyaltyProgram;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(loyaltyProgram.name),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.favorite_border)),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 116.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    loyaltyProgram.firstImageUrl != null
                        ? Image.network(
                          loyaltyProgram.firstImageUrl!,
                          width: getWidth(context),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              width: getWidth(context),
                              color: Colors.grey[200],
                              child: Icon(Icons.image_not_supported, size: 48),
                            );
                          },
                        )
                        : Container(
                          height: 200,
                          width: getWidth(context),
                          color: Colors.grey[200],
                          child: Icon(Icons.card_giftcard, size: 48),
                        ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                shape: BoxShape.circle,
                              ),
                              child:
                                  loyaltyProgram.businessLogoUrl != null
                                      ? ClipOval(
                                        child: Image.network(
                                          loyaltyProgram.businessLogoUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              color: Colors.grey[300],
                                              child: Icon(
                                                Icons.business,
                                                size: 20,
                                                color: Colors.grey[600],
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                      : Icon(
                                        Icons.business,
                                        size: 20,
                                        color: Colors.grey[600],
                                      ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              loyaltyProgram.businessName ?? 'Business',
                              style: TextStyle(fontSize: 25),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("Reward", style: TextStyle(fontSize: 12)),
                            Text(
                              loyaltyProgram.rewardDescription,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Text(
                          loyaltyProgram.name,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      loyaltyProgram.rewardDescription,
                      style: TextStyle(fontSize: 15, color: greyText),
                    ),
                    SizedBox(height: 30),
                    Row(
                      children: [
                        Text(
                          "Oferta",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Info",
                          style: TextStyle(fontSize: 18, color: greyText),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Lokacionet",
                          style: TextStyle(fontSize: 18, color: greyText),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Consumer<LoyaltyProgramProvider>(
                      builder: (context, loyaltyProgramProvider, _) {
                        final otherPrograms =
                            loyaltyProgramProvider.loyaltyPrograms
                                .where((p) => p.id != loyaltyProgram.id)
                                .toList();
                        if (loyaltyProgramProvider.isLoading &&
                            otherPrograms.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: primaryColor,
                              ),
                            ),
                          );
                        }
                        if (otherPrograms.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 12),
                            ...otherPrograms.map(
                              (program) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _OtherProgramCard(program: program),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 150),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            height: 140,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: secondBorderColor, width: 1),
                ),
              ),
              child: Consumer<CustomerLoyaltyCardProvider>(
                builder: (context, customerLoyaltyCardProvider, _) {
                  final currentStamps = customerLoyaltyCardProvider
                      .getStampsForProgram(loyaltyProgram.id);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(loyaltyProgram.stampsRequired, (
                          index,
                        ) {
                          final isFilled = index < currentStamps;
                          return Container(
                            height: 30,
                            width: 30,
                            margin: EdgeInsets.only(
                              right:
                                  loyaltyProgram.stampsRequired < 10 ? 10 : 5,
                            ),
                            decoration: BoxDecoration(
                              color: isFilled ? primaryColor : Colors.grey[300],
                              shape: BoxShape.circle,
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
                      customButton(context, 'Collect Reward'),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtherProgramCard extends StatelessWidget {
  final LoyaltyProgram program;

  const _OtherProgramCard({required this.program});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OfferDetail(loyaltyProgram: program),
          ),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: getWidth(context),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: primaryColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  program.firstImageUrl != null
                      ? Image.network(
                        program.firstImageUrl!,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _programImagePlaceholder(80);
                        },
                      )
                      : program.businessLogoUrl != null
                      ? Image.network(
                        program.businessLogoUrl!,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _programImagePlaceholder(80);
                        },
                      )
                      : _programImagePlaceholder(80),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.name,
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    program.rewardDescription,
                    style: TextStyle(fontSize: 15, color: greyText),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _programImagePlaceholder(double size) {
    return Container(
      height: size,
      width: size,
      color: Colors.grey[200],
      child: Icon(Icons.card_giftcard, size: 32, color: Colors.grey[600]),
    );
  }
}
