// lib/features/regularisation/presentation/providers/regularisation_provider.dart
// Only provider definition - creates notifier instance

import 'package:appattendance/features/regularisation/presentation/providers/regularisation_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final regularisationProvider =
    StateNotifierProvider<RegularisationNotifier, RegularisationState>(
      (ref) => RegularisationNotifier(ref),
    );
