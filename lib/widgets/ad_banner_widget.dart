import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';

/// Widget que muestra un banner de publicidad para usuarios no-premium.
/// Para usuarios premium, devuelve un SizedBox vacío.
///
/// En producción: reemplazar el contenido simulado con un BannerAd de AdMob.
/// Para el prototipo/demo: muestra un banner estático placeholder.
class AdBannerWidget extends StatelessWidget {
  const AdBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<AuthProvider>().isPremium;
    if (isPremium) return const SizedBox.shrink();

    return Container(
      height: 52,
      color: Colors.white,
      child: Row(
        children: [
          Container(
            width: 4,
            color: AppColors.accent,
          ),
          const SizedBox(width: 12),
          const Icon(Icons.campaign_outlined,
              size: 20, color: AppColors.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Anuncio · Publicidad no invasiva',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'AD',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary.withOpacity(0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
