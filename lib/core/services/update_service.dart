import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/update_dialog.dart';

class AppUpdateInfo {
  final String version;
  final int buildNumber;
  final String downloadUrl;
  final List<String> releaseNotes;
  final bool forceUpdate;

  AppUpdateInfo({
    required this.version,
    required this.buildNumber,
    required this.downloadUrl,
    required this.releaseNotes,
    this.forceUpdate = false,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      version: json['version'] ?? '1.0.0',
      buildNumber: json['build_number'] is int
          ? json['build_number']
          : int.tryParse(json['build_number']?.toString() ?? '1') ?? 1,
      downloadUrl: json['download_url'] ?? '',
      releaseNotes: (json['release_notes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['General performance updates and bug fixes.'],
      forceUpdate: json['force_update'] ?? false,
    );
  }
}

class AppUpdateService {
  /// Default remote config URL (Replace with your GitHub Gist, Raw GitHub file, or server endpoint)
  static const String _defaultConfigUrl =
      'https://raw.githubusercontent.com/ColorCraftPaints/app-config/main/version_config.json';

  static bool _hasCheckedThisSession = false;

  /// Check for updates on startup
  static Future<void> checkForUpdates(
    BuildContext context, {
    String? customConfigUrl,
    bool isManualCheck = false,
  }) async {
    if (_hasCheckedThisSession && !isManualCheck) return;
    _hasCheckedThisSession = true;

    try {
      final localInfo = await PackageInfo.fromPlatform();
      final localBuildNumber = int.tryParse(localInfo.buildNumber) ?? 1;
      final localVersion = localInfo.version;

      final configUrl = customConfigUrl ?? _defaultConfigUrl;
      final response = await http
          .get(Uri.parse(configUrl))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
        final remoteInfo = AppUpdateInfo.fromJson(jsonMap);

        final isNewerBuild = remoteInfo.buildNumber > localBuildNumber;
        final isNewerVersion =
            _compareVersions(remoteInfo.version, localVersion) > 0;

        if ((isNewerBuild || isNewerVersion) && context.mounted) {
          // Check if user dismissed this version unless it's a forced update or manual check
          final prefs = await SharedPreferences.getInstance();
          final dismissedVersion =
              prefs.getString('dismissed_update_version');

          if (!context.mounted) return;
          if (isManualCheck ||
              remoteInfo.forceUpdate ||
              dismissedVersion != remoteInfo.version) {
            showDialog(
              context: context,
              barrierDismissible: !remoteInfo.forceUpdate,
              builder: (ctx) => UpdateDialog(
                currentVersion: '$localVersion ($localBuildNumber)',
                newVersion: '${remoteInfo.version} (${remoteInfo.buildNumber})',
                releaseNotes: remoteInfo.releaseNotes,
                downloadUrl: remoteInfo.downloadUrl,
                forceUpdate: remoteInfo.forceUpdate,
                onDismiss: () async {
                  await prefs.setString(
                      'dismissed_update_version', remoteInfo.version);
                },
              ),
            );
          }
        } else if (isManualCheck && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Your app is up to date! Current version: v$localVersion'),
            ),
          );
        }
      }
    } catch (_) {
      // Quietly ignore network failures during auto-check on startup
      if (isManualCheck && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Unable to check for updates right now. Please check internet connection.'),
          ),
        );
      }
    }
  }

  /// Helper to launch APK download URL
  static Future<void> launchUpdateUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Version comparison helper (e.g. "1.1.0" vs "1.0.0")
  static int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;
      if (p1 > p2) return 1;
      if (p1 < p2) return -1;
    }
    return 0;
  }
}
