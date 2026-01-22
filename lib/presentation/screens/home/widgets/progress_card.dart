import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../providers/selfcare_provider.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SelfCareProvider>(
      builder: (context, provider, child) {
        final progress = provider.todayProgress / 100;
        
        return CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress Hari Ini',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '${provider.todayCompletedCount}/${provider.totalActivities}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.spaceMD),
              
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: AppColors.grey200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(provider.todayCompletedCount),
                  ),
                ),
              ),
              
              const SizedBox(height: AppDimensions.spaceSM),
              
              // Progress Text
              Text(
                _getProgressText(provider.todayCompletedCount, provider.totalActivities),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getProgressColor(int completed) {
    if (completed == 0) return AppColors.grey400;
    if (completed < 3) return AppColors.warning;
    if (completed < 5) return AppColors.info;
    return AppColors.success;
  }

  String _getProgressText(int completed, int total) {
    if (completed == 0) {
      return 'Belum ada aktivitas yang ditandai hari ini';
    } else if (completed < 3) {
      return 'Awal yang bagus! Terus lanjutkan!';
    } else if (completed < total) {
      return 'Hampir selesai! Tinggal sedikit lagi!';
    } else {
      return 'Sempurna! Semua aktivitas hari ini sudah selesai! 🎉';
    }
  }
}