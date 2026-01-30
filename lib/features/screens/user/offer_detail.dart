import 'package:flutter/material.dart';
import 'package:loyalty/core/dimensions.dart';
import 'package:loyalty/core/ui.dart';
import 'package:loyalty/features/components/components.dart';
import '../../models/loyalty_program_model.dart';

class OfferDetail extends StatelessWidget {
  final LoyaltyProgram loyaltyProgram;
  final int currentStamps;

  const OfferDetail({
    super.key,
    required this.loyaltyProgram,
    this.currentStamps = 0,
  });

  @override
  Widget build(BuildContext context) {
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
                              child: loyaltyProgram.businessLogoUrl != null
                                  ? ClipOval(
                                      child: Image.network(
                                        loyaltyProgram.businessLogoUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
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
                              loyaltyProgram.rewardType,
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
                          "Offers",
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
                          "Locations",
                          style: TextStyle(fontSize: 18, color: greyText),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: getWidth(context),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: primaryColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Image.asset("assets/kfc.png"),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Original Box",
                                  style: TextStyle(
                                    color: primaryTextColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "5,99€",
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  "1 Original Burger, 1 Drink, 1 French fries",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: greyText,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: getWidth(context),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: primaryColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Image.asset("assets/kfc.png"),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Original Box",
                                  style: TextStyle(
                                    color: primaryTextColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "5,99€",
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  "1 Original Burger, 1 Drink, 1 French fries",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: greyText,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      loyaltyProgram.stampsRequired,
                      (index) {
                        final isFilled = index < currentStamps;
                        return Container(
                          height: 30,
                          width: 30,
                          margin: EdgeInsets.only(
                            right: loyaltyProgram.stampsRequired < 10 ? 10 : 5,
                          ),
                          decoration: BoxDecoration(
                            color: isFilled ? primaryColor : Colors.grey[300],
                            shape: BoxShape.circle,
                            border: isFilled
                                ? null
                                : Border.all(
                                    color: primaryColor.withOpacity(0.5),
                                    width: 1.5,
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                  customButton(context,'Collect Reward'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
