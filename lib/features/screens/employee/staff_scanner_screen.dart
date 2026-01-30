import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/dimensions.dart';
import '../../../core/ui.dart';
import '../../components/components.dart';
import '../../models/business_model.dart';
import '../../providers/staff_scanner_provider.dart';
import 'camera_scanner_page.dart';

class StaffScannerScreen extends StatefulWidget {
  final Business business;
  final String businessUserId;
  final String locationId;

  const StaffScannerScreen({
    super.key,
    required this.business,
    required this.businessUserId,
    required this.locationId,
  });

  @override
  State<StaffScannerScreen> createState() => _StaffScannerScreenState();
}

class _StaffScannerScreenState extends State<StaffScannerScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = StaffScannerProvider();
        // Load loyalty programs when provider is created
        WidgetsBinding.instance.addPostFrameCallback((_) {
          provider.loadLoyaltyPrograms(widget.business.id);
        });
        return provider;
      },
      child: Consumer<StaffScannerProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(widget.business.name,style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
            ),
            body: Column(
              children: [
                // Loyalty Programs Section
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Select a Loyalty Program",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (provider.isLoadingPrograms)
                          const Center(child: CircularProgressIndicator())
                        else if (provider.hasError)
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'Error: ${provider.error!.message}',
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed:
                                      () => provider.loadLoyaltyPrograms(
                                        widget.business.id,
                                      ),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        else if (provider.loyaltyPrograms.isEmpty)
                          const Center(
                            child: Text('No active loyalty programs available'),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemCount: provider.loyaltyPrograms.length,
                            itemBuilder: (context, index) {
                              final program = provider.loyaltyPrograms[index];
                              final isSelected =
                                  provider.selectedProgram?.id == program.id;
                              final isActive = program.isActive;
                              return GestureDetector(
                                onTap: isActive
                                    ? () => provider.selectProgram(program)
                                    : null,
                                child: Container(
                                  width: getWidth(context),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: isSelected
                                          ? primaryColor
                                          : isActive
                                              ? primaryColor.withOpacity(0.5)
                                              : Colors.grey,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    color: isSelected
                                        ? primaryColor.withOpacity(0.1)
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      if (program.images.isNotEmpty &&
                                          program.images[0].signedUrl != null)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            program.images[0].signedUrl!,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                width: 100,
                                                height: 100,
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.image,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      else
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.image,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    program.name,
                                                    style: TextStyle(
                                                      color: primaryTextColor,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                if (isSelected)
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: primaryColor,
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "${program.stampsRequired} stamps",
                                              style: TextStyle(
                                                color: primaryColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              program.rewardDescription,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: greyText,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                            if (!isActive)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                        top: 4),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: const Text(
                                                    'Inactive',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: provider.selectedProgram != null
                ? Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider.value(
                              value: provider,
                              child: CameraScannerPage(
                                business: widget.business,
                                businessUserId: widget.businessUserId,
                                locationId: widget.locationId,
                                selectedProgram: provider.selectedProgram!,
                              ),
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: customButton(context, "SCAN QR Code"),
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Opacity(
                      opacity: 0.5,
                      child: customButton(context,"Select a product"),
                    ),
                  ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        },
      ),
    );
  }
}
