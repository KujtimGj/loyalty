import 'package:flutter/material.dart';
import '../../../../core/dimensions.dart';
import '../../../../core/ui.dart';
import '../../../models/business_model.dart';
import '../../../models/loyalty_program_model.dart';
import '../../../controllers/loyalty_program_controller.dart';
import '../../../../core/failures.dart';

class BusinessDetailPage extends StatefulWidget {
  final Business business;

  const BusinessDetailPage({
    super.key,
    required this.business,
  });

  @override
  State<BusinessDetailPage> createState() => _BusinessDetailPageState();
}

class _BusinessDetailPageState extends State<BusinessDetailPage> {
  List<LoyaltyProgram> _loyaltyPrograms = [];
  bool _isLoading = false;
  Failure? _failure;

  @override
  void initState() {
    super.initState();
    print('🟡 [BusinessDetailPage] initState called for business: ${widget.business.name}');
    _fetchLoyaltyPrograms();
  }

  Future<void> _fetchLoyaltyPrograms() async {
    setState(() {
      _isLoading = true;
      _failure = null;
    });

    print('🟡 [BusinessDetailPage] Fetching loyalty programs for business: ${widget.business.id}');
    final result = await LoyaltyProgramController.fetchLoyaltyProgramsByBusiness(
      widget.business.id,
    );

    result.fold(
      (failure) {
        print('❌ [BusinessDetailPage] Failed to fetch loyalty programs: ${failure.message}');
        setState(() {
          _failure = failure;
          _loyaltyPrograms = [];
          _isLoading = false;
        });
      },
      (programs) {
        print('✅ [BusinessDetailPage] Successfully fetched ${programs.length} loyalty programs');
        setState(() {
          _loyaltyPrograms = programs;
          _failure = null;
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          children: [
            Image.network("${widget.business.logoUrl}",width: 50,height: 50,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.business.name),
                Text(widget.business.email)
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business Details Section
            _buildBusinessDetailsSection(),
            _buildLoyaltyProgramsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessDetailsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informacioni i Biznesit',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(widget.business.name)
        ],
      ),
    );
  }

  Widget _buildLoyaltyProgramsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ofertat',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading && _loyaltyPrograms.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_failure != null)
            _buildErrorWidget()
          else if (_loyaltyPrograms.isEmpty)
            _buildEmptyState()
          else
            ..._loyaltyPrograms.map((program) => _buildLoyaltyProgramCard(program)),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Gabim në ngarkimin e programeve të besnikërisë',
              style: TextStyle(color: Colors.red[700]),
            ),
            const SizedBox(height: 8),
            Text(
              _failure?.message ?? 'Gabim i panjohur',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchLoyaltyPrograms,
              icon: const Icon(Icons.refresh),
              label: const Text('Provo Përsëri'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.card_giftcard_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Asnjë program besnikërie i disponueshëm',
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

  Widget _buildLoyaltyProgramCard(LoyaltyProgram program) {
    return Container(
      width: getWidth(context),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: primaryColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center ,
        children: [
          Row(
            children: [
              Image.network("${program.businessLogoUrl}", height: 120,),
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
                      program.price.toString(),
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      program.rewardDescription,
                      style: TextStyle(fontSize: 12, color: greyText),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 25,
                width: 25,
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kfcRed,
                ),
              ),
              Container(
                height: 25,
                width: 25,
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kfcRed,
                ),
              ),
              Container(
                height: 25,
                width: 25,
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kfcRed,
                ),
              ),
              Container(
                height: 25,
                width: 25,
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kfcRed,
                ),
              ),
              Container(
                height: 25,
                width: 25,
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kfcRed,
                ),
              ),
              Container(
                height: 25,
                width: 25,
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kfcRed,
                ),
              ),
              Container(
                height: 25,
                width: 25,
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kfcRed,
                ),
              ),
              Container(
                height: 25,
                width: 25,
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kfcRed,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
