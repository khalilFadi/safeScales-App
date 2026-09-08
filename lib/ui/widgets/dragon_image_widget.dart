import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../models/dragon.dart';
import '../../providers/course_provider.dart';
import '../../providers/dragon_provider.dart';
import 'safe_network_or_asset_image.dart';

class DragonImageWidget extends StatelessWidget {
  final String? dragonId;
  final String? moduleId;
  final double size;
  final String? phase;

  const DragonImageWidget({
    super.key,
    this.dragonId,
    this.moduleId,
    required this.size,
    this.phase,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<DragonProvider, CourseProvider>(
      builder: (context, dragonProvider, courseProvider, child) {
        Dragon? dragon;
        if (moduleId != null) {
          dragon = dragonProvider.getDragonByModuleId(moduleId!);
        } else if (dragonId != null) {
          dragon = dragonProvider.getDragonById(dragonId!);
        }

        String imageUrl = 'assets/images/other/QuestionMark.png';
        if (dragon != null) {
          final resolved = dragonProvider.getDragonImageUrl(
            dragon.id,
            forPhase: phase ?? dragonProvider.getDragonHighestPhase(dragon.id),
          );
          if (resolved.trim().isNotEmpty) {
            imageUrl = resolved;
          }
        }

        return SafeNetworkOrAssetImage(
          imageUrl: imageUrl,
          width: size,
          height: size,
        );
      },
    );
  }
}
