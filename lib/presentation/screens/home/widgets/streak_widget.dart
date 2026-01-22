import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/widgets/custom_card.dart';
import '../../../providers/selfcare_provider.dart';

class StreakWidget extends StatelessWidget {
  const StreakWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SelfCareProvider>(
      builder: (context, provider, child) {
        return CustomCard(
          backgroundColor: AppColors.primary,
          child: Row(
            children: [
              // Flame Icon
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingMD),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: AppDimensions.iconXL,
                ),
              ),
              
              const SizedBox(width: AppDimensions.spaceMD),
              
              // Streak Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Streak',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceXS),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${provider.streak}',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spaceSM),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'hari',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spaceXS),
                    Text(
                      provider.streak == 0
                          ? 'Mulai tandai aktivitas untuk membangun streak!'
                          : provider.streak == 1
                              ? 'Pertahankan! Jangan putus!'
                              : 'Luar biasa! Terus pertahankan!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}