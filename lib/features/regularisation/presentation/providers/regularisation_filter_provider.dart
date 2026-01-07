// lib/features/regularisation/presentation/providers/regularisation_filter_provider.dart

import 'package:appattendance/features/regularisation/domain/models/regularisation_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final regularisationFilterProvider = StateProvider<RegularisationFilter>(
  (ref) => RegularisationFilter.all,
);
