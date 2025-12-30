// // In Profile screen (ConsumerWidget)
// final user = ref.watch(userProfileProvider);
// final isLoaded = ref.watch(isProfileLoadedProvider);

// if (!isLoaded) {
//   return const Center(child: CircularProgressIndicator());
// }

// if (user == null) {
//   return const Text('Not logged in');
// }

// // Show profile data
// Text('Phone: ${user.phone ?? 'Not set'}');
// Text('Emergency Contact: ${user.emergencyContact ?? 'Not set'}');

// // Update profile example (button onPressed)
// ref.read(updateProfileProvider.notifier).update({
//   'phone': '9876543210',
//   'emergency': '1234567890',
// });
