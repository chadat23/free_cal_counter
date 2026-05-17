class MergeResult {
  final int keeperId;
  final int loserId;
  final int loggedRepointed;
  final int recipeRepointed;
  final int parentChainsRepointed;
  final int portionsDropped;
  final int barcodesDropped;
  final List<int> sampleLoggedTimestamps;

  const MergeResult({
    required this.keeperId,
    required this.loserId,
    required this.loggedRepointed,
    required this.recipeRepointed,
    required this.parentChainsRepointed,
    required this.portionsDropped,
    required this.barcodesDropped,
    required this.sampleLoggedTimestamps,
  });
}

class MergePredictedCounts {
  final int loggedToRepoint;
  final int recipeToRepoint;
  final int parentChainsToRepoint;
  final int portionsToDrop;
  final int barcodesToDrop;

  const MergePredictedCounts({
    required this.loggedToRepoint,
    required this.recipeToRepoint,
    required this.parentChainsToRepoint,
    required this.portionsToDrop,
    required this.barcodesToDrop,
  });
}

class MergeIntegrityException implements Exception {
  final String message;
  const MergeIntegrityException(this.message);

  @override
  String toString() => 'MergeIntegrityException: $message';
}
