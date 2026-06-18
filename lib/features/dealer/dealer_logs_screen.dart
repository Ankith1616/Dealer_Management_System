import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/models/visit_log_model.dart';
import '../../data/repositories/log_repository.dart';

class DealerLogsScreen extends ConsumerStatefulWidget {
  const DealerLogsScreen({super.key});

  @override
  ConsumerState<DealerLogsScreen> createState() => _DealerLogsScreenState();
}

class _DealerLogsScreenState extends ConsumerState<DealerLogsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRoleFilter = 'All'; // 'All', 'Customer', 'Dealer'
  String _sortBy = 'Last Visited'; // 'Last Visited', 'Visit Count', 'Name'
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.isNegative || difference.inSeconds < 15) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return '$mins min${mins > 1 ? "s" : ""} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours hour${hours > 1 ? "s" : ""} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days day${days > 1 ? "s" : ""} ago';
    } else {
      return Helpers.formatDate(dateTime);
    }
  }

  Color _getAvatarColor(String name) {
    final hash = name.codeUnits.fold(0, (prev, elem) => prev + elem);
    final colors = [
      Colors.indigo,
      Colors.teal,
      Colors.blue,
      Colors.purple,
      Colors.deepOrange,
      Colors.blueGrey,
    ];
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(visitLogsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 900;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Visitor Logs',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear All Logs',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Visitor Logs'),
                  content: const Text('Are you sure you want to clear all visitor logs? This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(logRepositoryProvider).clearVisitLogs();
                ref.invalidate(visitLogsProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Visitor logs cleared successfully.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: logsAsync.when(
          data: (logs) {
            // Group logs by unique user (uid or phone number)
            final Map<String, List<VisitLogModel>> grouped = {};
            for (final log in logs) {
              final key = log.uid.isNotEmpty ? log.uid : log.phoneNumber;
              grouped.putIfAbsent(key, () => []).add(log);
            }

            final uniqueUsers = grouped.entries.map((entry) {
              final userLogs = entry.value;
              userLogs.sort((a, b) => b.lastVisited.compareTo(a.lastVisited));
              final latestLog = userLogs.first;
              final maxVisits = userLogs.map((l) => l.visitCount).reduce((a, b) => a > b ? a : b);
              return _GroupedUserLogs(
                user: latestLog,
                allLogs: userLogs,
                totalVisits: maxVisits,
              );
            }).toList();

            // Calculate Statistics
            final uniqueCount = uniqueUsers.length;
            final totalCount = uniqueUsers.fold<int>(0, (sum, item) => sum + item.totalVisits);
            final customerCount = uniqueUsers
                .where((item) => item.user.role.toLowerCase() == 'customer')
                .fold<int>(0, (sum, item) => sum + item.totalVisits);
            final dealerCount = uniqueUsers
                .where((item) => item.user.role.toLowerCase() == 'dealer')
                .fold<int>(0, (sum, item) => sum + item.totalVisits);

            // Filter Users
            var filteredUsers = uniqueUsers.where((item) {
              final log = item.user;
              final nameMatch = log.displayName.toLowerCase().contains(_searchQuery);
              final emailMatch = log.email?.toLowerCase().contains(_searchQuery) ?? false;
              final phoneMatch = log.phoneNumber.contains(_searchQuery);
              final matchesSearch = nameMatch || emailMatch || phoneMatch;

              if (_selectedRoleFilter == 'All') {
                return matchesSearch;
              } else {
                return matchesSearch &&
                    log.role.toLowerCase() == _selectedRoleFilter.toLowerCase();
              }
            }).toList();

            // Sort Users
            filteredUsers.sort((a, b) {
              int cmp;
              if (_sortBy == 'Name') {
                cmp = a.user.displayName.toLowerCase().compareTo(b.user.displayName.toLowerCase());
              } else if (_sortBy == 'Visit Count') {
                cmp = a.totalVisits.compareTo(b.totalVisits);
              } else {
                // Last Visited
                cmp = a.user.lastVisited.compareTo(b.user.lastVisited);
              }
              return _sortAscending ? cmp : -cmp;
            });

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.p20,
                vertical: AppSizes.p16,
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Subtitle
                      Text(
                        'Track user engagement and check active logins on the site.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.white60 : Colors.grey[700],
                            ),
                      ),
                      const SizedBox(height: AppSizes.p20),

                      // Metrics Cards Row
                      GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isLargeScreen ? 4 : (size.width > 600 ? 2 : 1),
                          crossAxisSpacing: AppSizes.p16,
                          mainAxisSpacing: AppSizes.p16,
                          childAspectRatio: isLargeScreen ? 1.6 : 2.2,
                        ),
                        children: [
                          _buildMetricCard(
                            context: context,
                            title: 'Total Visits',
                            value: '$totalCount',
                            subtitle: 'All portal load activities',
                            icon: Icons.analytics_outlined,
                            gradientColors: [Colors.indigo[800]!, Colors.indigo[500]!],
                          ),
                          _buildMetricCard(
                            context: context,
                            title: 'Unique Visitors',
                            value: '$uniqueCount',
                            subtitle: 'Registered accounts logged in',
                            icon: Icons.people_outline_rounded,
                            gradientColors: [Colors.teal[800]!, Colors.teal[500]!],
                          ),
                          _buildMetricCard(
                            context: context,
                            title: 'Customer Page Views',
                            value: '$customerCount',
                            subtitle: 'Visits on user portal',
                            icon: Icons.person_pin_circle_outlined,
                            gradientColors: [Colors.amber[900]!, Colors.amber[600]!],
                          ),
                          _buildMetricCard(
                            context: context,
                            title: 'Dealer Page Views',
                            value: '$dealerCount',
                            subtitle: 'Visits on dashboard',
                            icon: Icons.admin_panel_settings_outlined,
                            gradientColors: [Colors.purple[800]!, Colors.purple[500]!],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.p24),

                      // Filter Dashboard card
                      GlassCard(
                        padding: const EdgeInsets.all(AppSizes.p16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.tune_rounded, size: 20, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Filter & Sort Options',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.p16),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isCompact = constraints.maxWidth < 650;
                                return isCompact
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: _buildFilterFields(isDark),
                                      )
                                    : Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: _buildFilterFields(isDark),
                                      );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.p20),

                      // Visitors Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Active Visitor Feed (${filteredUsers.length})',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded),
                            tooltip: 'Refresh Feed',
                            onPressed: () {
                              ref.invalidate(visitLogsProvider);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.p12),

                      if (filteredUsers.isEmpty)
                        GlassCard(
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 64,
                                  color: isDark ? Colors.white30 : Colors.grey[400],
                                ),
                                const SizedBox(height: AppSizes.p16),
                                Text(
                                  'No visitor logs found',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: isDark ? Colors.white70 : Colors.grey[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: AppSizes.p4),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Try resetting the search terms or filters.'
                                      : 'Visit logs will appear once users log in and browse pages.',
                                  style: TextStyle(
                                    color: isDark ? Colors.white30 : Colors.grey[500],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (isLargeScreen)
                        _buildDesktopLogsTable(filteredUsers, isDark)
                      else
                        _buildMobileLogsList(filteredUsers, isDark),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Fetching portal visitor logs...'),
                ],
              ),
            ),
          ),
          error: (e, s) => Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text('Failed to load logs: $e', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(visitLogsProvider),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFilterFields(bool isDark) {
    return [
      // Search Box
      Expanded(
        flex: 3,
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search visitor name, phone...',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () => _searchController.clear(),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ),
      const SizedBox(width: AppSizes.p16, height: AppSizes.p12),

      // Role filter chips
      Row(
        mainAxisSize: MainAxisSize.min,
        children: ['All', 'Customer', 'Dealer'].map((role) {
          final isSelected = _selectedRoleFilter == role;
          return Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: ChoiceChip(
              label: Text(
                role,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.grey[800]),
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[200],
              onSelected: (val) {
                if (val) {
                  setState(() {
                    _selectedRoleFilter = role;
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
      const SizedBox(width: AppSizes.p16, height: AppSizes.p12),

      // Sort criteria selector
      DropdownButtonHideUnderline(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? Colors.white24 : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sort_rounded, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _sortBy,
                items: ['Last Visited', 'Visit Count', 'Name'].map((criterion) {
                  return DropdownMenuItem(
                    value: criterion,
                    child: Text(criterion, style: const TextStyle(fontSize: 12)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      if (_sortBy == val) {
                        _sortAscending = !_sortAscending;
                      } else {
                        _sortBy = val;
                        _sortAscending = val == 'Name'; // default sort A-Z for names, desc for count/date
                      }
                    });
                  }
                },
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  _sortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
                onPressed: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              icon,
              size: 80,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(icon, size: 18, color: Colors.white70),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLogsTable(List<_GroupedUserLogs> logs, bool isDark) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Headers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey[100],
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white12 : Colors.grey[200]!,
                ),
              ),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('User Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 2, child: Text('Role', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 3, child: Text('Contact Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 2, child: Text('Visits', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 2, child: Text('Last Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 2, child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              ],
            ),
          ),

          // Table Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: logs.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: isDark ? Colors.white12 : Colors.grey[200],
            ),
            itemBuilder: (context, index) {
              final item = logs[index];
              return _buildDesktopRow(context, item, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopRow(BuildContext context, _GroupedUserLogs item, bool isDark) {
    final log = item.user;
    final avatarColor = _getAvatarColor(log.displayName);
    final initials = log.displayName.isNotEmpty
        ? log.displayName.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'U';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          // Avatar + Name
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: avatarColor.withValues(alpha: 0.2),
                  child: Text(
                    initials,
                    style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    log.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Role Badge
          Expanded(
            flex: 2,
            child: _buildRoleBadge(log.role),
          ),

          // Email & Phone
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  log.phoneNumber,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                if (log.email != null && log.email!.isNotEmpty)
                  Text(
                    log.email!,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Visit Count
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${item.totalVisits} visits',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Last Active
          Expanded(
            flex: 2,
            child: Tooltip(
              message: log.lastVisited.toString(),
              child: Text(
                _getRelativeTime(log.lastVisited),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),

          // Action
          Expanded(
            flex: 2,
            child: Row(
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                  ),
                  onPressed: () => _showDetailedLogsDialog(context, item),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Observe Logs',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.primary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLogsList(List<_GroupedUserLogs> uniqueUsers, bool isDark) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: uniqueUsers.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSizes.p12),
      itemBuilder: (context, index) {
        final item = uniqueUsers[index];
        final log = item.user;
        final avatarColor = _getAvatarColor(log.displayName);
        final initials = log.displayName.isNotEmpty
            ? log.displayName.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
            : 'U';

        return GlassCard(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header profile row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: avatarColor.withValues(alpha: 0.2),
                    child: Text(
                      initials,
                      style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildRoleBadge(log.role),
                            const SizedBox(width: 8),
                            Text(
                              '${item.totalVisits} visits',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white60 : Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _getRelativeTime(log.lastVisited),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Contact Details Section
              Row(
                children: [
                  const Icon(Icons.phone_rounded, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    log.phoneNumber,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  if (log.email != null && log.email!.isNotEmpty) ...[
                    const Spacer(),
                    const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 4,
                      child: Text(
                        log.email!,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              
              // Observe Logs Action Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                  ),
                  onPressed: () => _showDetailedLogsDialog(context, item),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Observe Logs',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDetailedLogsDialog(BuildContext context, _GroupedUserLogs item) {
    final log = item.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history_toggle_off_rounded, color: AppColors.primary, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Log History: ${log.displayName}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Role: ${log.role.toUpperCase()} | Phone: ${log.phoneNumber}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: item.allLogs.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: isDark ? Colors.white12 : Colors.grey[200],
                  ),
                  itemBuilder: (context, index) {
                    final visit = item.allLogs[index];
                    final timeStr = Helpers.formatDate(visit.lastVisited);
                    
                    // Format time to 12 hour string with AM/PM
                    final hour = visit.lastVisited.hour;
                    final minute = visit.lastVisited.minute;
                    final amPm = hour >= 12 ? 'PM' : 'AM';
                    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
                    final displayMinute = minute.toString().padLeft(2, '0');
                    final timeOnlyStr = '$displayHour:$displayMinute $amPm';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.login_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Visit #${visit.visitCount}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$timeStr at $timeOnlyStr',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            _getRelativeTime(visit.lastVisited),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    final isDealer = role.toLowerCase() == 'dealer';
    final bgColor = isDealer
        ? AppColors.secondary.withValues(alpha: 0.15)
        : AppColors.accent.withValues(alpha: 0.15);
    final textColor = isDealer
        ? AppColors.secondaryDark
        : AppColors.accent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _GroupedUserLogs {
  final VisitLogModel user;
  final List<VisitLogModel> allLogs;
  final int totalVisits;

  _GroupedUserLogs({
    required this.user,
    required this.allLogs,
    required this.totalVisits,
  });
}
