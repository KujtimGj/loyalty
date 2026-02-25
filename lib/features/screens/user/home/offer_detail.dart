import 'package:flutter/material.dart';
import 'package:loyalty/core/dimensions.dart';
import 'package:loyalty/core/ui.dart';
import 'package:loyalty/features/components/components.dart';
import 'package:provider/provider.dart';
import '../../../models/loyalty_program_model.dart';
import '../../../models/business_model.dart';
import '../../../models/business_location_model.dart';
import '../../../providers/customer_loyalty_card_provider.dart';
import '../../../providers/loyalty_program_provider.dart';
import '../../../providers/business_provider.dart';
import '../../../controllers/business_location_controller.dart';
import '../../../../core/failures.dart';

class OfferDetail extends StatefulWidget {
  final LoyaltyProgram loyaltyProgram;

  const OfferDetail({super.key, required this.loyaltyProgram});

  @override
  State<OfferDetail> createState() => _OfferDetailState();
}

class _OfferDetailState extends State<OfferDetail> {
  Business? _business;
  List<BusinessLocation> _locations = [];
  bool _isLoadingBusiness = false;
  bool _isLoadingLocations = false;
  Failure? _businessFailure;
  Failure? _locationsFailure;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<LoyaltyProgramProvider>()
          .fetchActiveLoyaltyProgramsByBusiness(
            widget.loyaltyProgram.businessId,
          );
      _fetchBusiness();
      _fetchLocations();
    });
  }

  Future<void> _fetchBusiness() async {
    setState(() {
      _isLoadingBusiness = true;
      _businessFailure = null;
    });

    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    final result = await businessProvider.fetchBusinessById(
      widget.loyaltyProgram.businessId,
    );

    result.fold(
      (failure) {
        setState(() {
          _businessFailure = failure;
          _isLoadingBusiness = false;
        });
      },
      (business) {
        setState(() {
          _business = business;
          _isLoadingBusiness = false;
        });
      },
    );
  }

  Future<void> _fetchLocations() async {
    setState(() {
      _isLoadingLocations = true;
      _locationsFailure = null;
    });

    final result = await BusinessLocationController.fetchLocationsByBusiness(
      widget.loyaltyProgram.businessId,
    );

    result.fold(
      (failure) {
        setState(() {
          _locationsFailure = failure;
          _isLoadingLocations = false;
        });
      },
      (locations) {
        setState(() {
          _locations = locations.where((loc) => loc.isActive).toList();
          _isLoadingLocations = false;
        });
      },
    );
  }

  int selectedIndex=0;
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
                          height: 200,
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
                              child: loyaltyProgram.businessLogoUrl != null &&
                                      loyaltyProgram.businessLogoUrl!.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        loyaltyProgram.businessLogoUrl!,
                                        height: 35,
                                        width: 35,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                      loadingProgress.expectedTotalBytes!
                                                  : null,
                                              strokeWidth: 2,
                                            ),
                                          );
                                        },
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
                              loyaltyProgram.businessName ?? 'Biznes',
                              style: TextStyle(fontSize: 25),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("Shpërblim", style: TextStyle(fontSize: 12)),
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
            left: 20,
            right: 20,
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
                      customButton(
                        context,
                        currentStamps >= loyaltyProgram.stampsRequired
                            ? 'Mblidh Shpërblimin'
                            : 'Skano kodin',
                      ),
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

  Widget _buildBusinessInfo() {
    if (_isLoadingBusiness) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    if (_businessFailure != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 8),
            Text(
              'Gabim në ngarkimin e informacionit të biznesit',
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _fetchBusiness,
              child: Text('Provo Përsëri'),
            ),
          ],
        ),
      );
    }

    if (_business == null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Informacioni i biznesit nuk është i disponueshëm',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.business, 'Emri i Biznesit', _business!.name),
          SizedBox(height: 16),
          _buildInfoRow(Icons.email, 'Email', _business!.email),
          SizedBox(height: 16),
          _buildInfoRow(Icons.phone, 'Telefon', _business!.phone),
          SizedBox(height: 16),
          _buildInfoRow(
            Icons.check_circle,
            'Statusi i Abonimit',
            _business!.subscriptionStatus == 'aktive' ? 'Aktive' : 'Joaktive',
          ),
          SizedBox(height: 16),
          _buildInfoRow(
            Icons.star,
            'Plan',
            _business!.plan == 'premium' ? 'Premium' : 'Falas',
          ),
          if (widget.loyaltyProgram.businessIndustry != null) ...[
            SizedBox(height: 16),
            _buildInfoRow(
              Icons.category,
              'Industria',
              widget.loyaltyProgram.businessIndustry!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: primaryColor, size: 24),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: greyText,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocations() {
    if (_isLoadingLocations) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    if (_locationsFailure != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 8),
            Text(
              'Gabim në ngarkimin e lokacioneve',
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _fetchLocations,
              child: Text('Provo Përsëri'),
            ),
          ],
        ),
      );
    }

    if (_locations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.location_off, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Asnjë lokacion i disponueshëm',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._locations.map((location) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildLocationCard(location),
              )),
        ],
      ),
    );
  }

  Widget _buildLocationCard(BusinessLocation location) {
    return Container(
      width: getWidth(context),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: primaryColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on, color: primaryColor, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: primaryTextColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  location.address,
                  style: TextStyle(
                    fontSize: 14,
                    color: greyText,
                  ),
                ),
              ],
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
