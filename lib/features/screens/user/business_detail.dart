import 'package:flutter/material.dart';
import '../../models/business_model.dart';
import '../../models/loyalty_program_model.dart';
import '../../controllers/loyalty_program_controller.dart';
import '../../../core/failures.dart';

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
        title: Text(widget.business.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business Details Section
            _buildBusinessDetailsSection(),
            const Divider(),
            // Loyalty Programs Section
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
            'Business Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            icon: Icons.business,
            label: 'Name',
            value: widget.business.name,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.email,
            label: 'Email',
            value: widget.business.email,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.phone,
            label: 'Phone',
            value: widget.business.phone,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.subscriptions,
            label: 'Subscription Status',
            value: widget.business.subscriptionStatus.toUpperCase(),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            icon: Icons.workspace_premium,
            label: 'Plan',
            value: widget.business.plan.toUpperCase(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
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
                'Loyalty Programs',
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
              'Error loading loyalty programs',
              style: TextStyle(color: Colors.red[700]),
            ),
            const SizedBox(height: 8),
            Text(
              _failure?.message ?? 'Unknown error',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchLoyaltyPrograms,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
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
              'No loyalty programs available',
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    program.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: program.isActive
                        ? Colors.green.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: program.isActive ? Colors.green : Colors.grey,
                    ),
                  ),
                  child: Text(
                    program.isActive ? 'ACTIVE' : 'INACTIVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: program.isActive ? Colors.green[700] : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.star, size: 20, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  '${program.stampsRequired} stamps required',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.card_giftcard, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    program.rewardDescription,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
