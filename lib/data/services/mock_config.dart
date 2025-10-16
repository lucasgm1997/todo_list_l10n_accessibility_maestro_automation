/// Configuration for MockTodoService
///
/// Use this file to configure the mock service for different test scenarios
class MockConfig {
  /// Minimum number of items to generate
  static const int minItems = 3;

  /// Maximum number of items to generate
  static const int maxItems = 10;

  /// Seed for deterministic random generation
  /// Set to null for random generation on each app start
  /// Set to a fixed value (e.g., 42) for deterministic testing
  static const int? seed = null; // Change to 42 for deterministic tests

  /// Pattern for generated titles
  /// Use {i} as placeholder for the index
  static const String titlePattern = 'Task {i}';

  /// Generate stable IDs for Maestro testing
  static const bool withStableIds = true;

  /// For deterministic testing, use these settings:
  static const int deterministicSeed = 42;
  static const int deterministicMin = 5;
  static const int deterministicMax = 5; // Fixed count for deterministic tests
}
