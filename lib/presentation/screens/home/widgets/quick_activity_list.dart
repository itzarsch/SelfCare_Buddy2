import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../providers/selfcare_provider.dart';

class QuickActivityList extends StatelessWidget {
  const QuickActivityList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SelfCareProvider>(
      builder: (context, provider, child) {
        return Column(
          children: provider.activities.map((activity) {
            final isCompleted = provider.isActivityCompleted(activity.id);
            
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
              child: CustomCard(
                onTap: () async {
                  await provider.toggleActivity(activity.id);
                },
                backgroundColor: isCompleted 
                    ? activity.color.withOpacity(0.1)
                    : AppColors.surface,
                child: Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingMD),
                      decoration: BoxDecoration(
                        color: activity.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      ),
                      child: Icon(
                        activity.icon,
                        color: activity.color,
                        size: AppDimensions.iconLG,
                      ),
                    ),
                    
                    const SizedBox(width: AppDimensions.spaceMD),
                    
                    // Activity Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              decoration: isCompleted 
                                  ? TextDecoration.lineThrough 
                                  : null,
                              color: isCompleted 
                                  ? AppColors.textSecondary 
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spaceXS),
                          Text(
                            activity.description,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Checkbox
                    Checkbox(
                      value: isCompleted,
                      onChanged: (value) async {
                        await provider.toggleActivity(activity.id);
                      },
                      activeColor: activity.color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}