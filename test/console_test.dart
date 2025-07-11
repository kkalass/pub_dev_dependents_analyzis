import 'package:console/package_analysis.dart';
import 'package:test/test.dart';

void main() {
  group('URL conversion tests', () {
    test('converts GitHub URL to raw pubspec.yaml URL', () {
      const repoUrl = 'https://github.com/user/repo';
      const expected =
          'https://raw.githubusercontent.com/user/repo/main/pubspec.yaml';

      final result = convertToPubspecRawUrl(repoUrl);

      expect(result, equals(expected));
    });

    test('converts GitHub URL with trailing slash to raw pubspec.yaml URL', () {
      const repoUrl = 'https://github.com/user/repo/';
      const expected =
          'https://raw.githubusercontent.com/user/repo/main/pubspec.yaml';

      final result = convertToPubspecRawUrl(repoUrl);

      expect(result, equals(expected));
    });

    test('converts GitLab URL to raw pubspec.yaml URL', () {
      const repoUrl = 'https://gitlab.com/user/repo';
      const expected = 'https://gitlab.com/user/repo/-/raw/main/pubspec.yaml';

      final result = convertToPubspecRawUrl(repoUrl);

      expect(result, equals(expected));
    });

    test('handles unknown repository hosts as fallback', () {
      const repoUrl = 'https://custom-git.com/user/repo';
      const expected = 'https://custom-git.com/user/repo/pubspec.yaml';

      final result = convertToPubspecRawUrl(repoUrl);

      expect(result, equals(expected));
    });
  });

  group('PubspecInfo extraction tests', () {
    test('extracts target package version from Map-based pubspec data', () {
      final pubspecData = {
        'name': 'example_package',
        'version': '1.0.0',
        'dependencies': {'analyzer': '^6.2.0'},
      };

      final result = extractPubspecInfo(pubspecData, 'analyzer');

      expect(result, isNotNull);
      expect(result!.version, equals('1.0.0'));
      expect(result.targetPackageVersion, equals('^6.2.0'));
    });

    test('extracts target package version from dev_dependencies section', () {
      final pubspecData = {
        'name': 'example_package',
        'version': '1.0.0',
        'dev_dependencies': {'analyzer': '^6.2.0'},
      };

      final result = extractPubspecInfo(pubspecData, 'analyzer');

      expect(result, isNotNull);
      expect(result!.version, equals('1.0.0'));
      expect(result.targetPackageVersion, equals('^6.2.0'));
    });

    test('returns null when no analyzer dependency is found', () {
      final pubspecData = {
        'name': 'example_package',
        'version': '1.0.0',
        'dependencies': {'http': '^0.13.0'},
      };

      final result = extractPubspecInfo(pubspecData, 'analyzer');

      expect(result, isNotNull);
      expect(result!.version, equals('1.0.0'));
      expect(result.targetPackageVersion, isNull);
    });

    test('handles null pubspec data gracefully', () {
      final result = extractPubspecInfo(null, 'analyzer');

      expect(result, isNull);
    });

    test('handles empty pubspec data gracefully', () {
      final result = extractPubspecInfo({}, 'analyzer');

      expect(result, isNotNull);
      expect(result!.version, equals('unknown'));
      expect(result.targetPackageVersion, isNull);
    });
  });
}
