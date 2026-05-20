import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class EngineeringScreen extends StatelessWidget {
  const EngineeringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroStats(),
          const SizedBox(height: 24),
          _BentoGrid(),
          const SizedBox(height: 24),
          _CriticalEngineeringPath(),
        ],
      ),
    );
  }
}

class _HeroStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 768;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (isWide) {
          return Row(
            children: const [
              Expanded(
                child: _StatCard(
                  title: 'TOTAL ACTIVE SQUADS',
                  value: '12',
                  delta: '2.4%',
                  isUp: true,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'RESOURCE UTILIZATION',
                  value: '94.2%',
                  delta: '0.8%',
                  isUp: false,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'VELOCITY INDEX',
                  value: '48.5',
                  delta: '12%',
                  isUp: true,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'SPRINT HEALTH',
                  value: 'Optimal',
                  isOptimal: true,
                ),
              ),
            ],
          );
        }
        return Column(
          children: const [
            _StatCard(
              title: 'TOTAL ACTIVE SQUADS',
              value: '12',
              delta: '2.4%',
              isUp: true,
            ),
            SizedBox(height: 16),
            _StatCard(
              title: 'RESOURCE UTILIZATION',
              value: '94.2%',
              delta: '0.8%',
              isUp: false,
            ),
            SizedBox(height: 16),
            _StatCard(
              title: 'VELOCITY INDEX',
              value: '48.5',
              delta: '12%',
              isUp: true,
            ),
            SizedBox(height: 16),
            _StatCard(
              title: 'SPRINT HEALTH',
              value: 'Optimal',
              isOptimal: true,
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? delta;
  final bool? isUp;
  final bool isOptimal;

  const _StatCard({
    required this.title,
    required this.value,
    this.delta,
    this.isUp,
    this.isOptimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                if (isOptimal)
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                  )
                else if (delta != null)
                  Row(
                    children: [
                      Icon(
                        isUp! ? Icons.trending_up : Icons.trending_down,
                        size: 16,
                        color: isUp! ? AppColors.secondary : AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        delta!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isUp! ? AppColors.secondary : AppColors.error,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BentoGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1024;
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(flex: 8, child: _TeamAllocationMatrix()),
          const SizedBox(width: 24),
          Expanded(
            flex: 4,
            child: Column(
              children: const [
                _NextDeployment(),
                SizedBox(height: 24),
                _SkillDistribution(),
              ],
            ),
          ),
        ],
      );
    }
    return Column(
      children: const [
        _TeamAllocationMatrix(),
        SizedBox(height: 24),
        _NextDeployment(),
        SizedBox(height: 24),
        _SkillDistribution(),
      ],
    );
  }
}

class _TeamAllocationMatrix extends StatelessWidget {
  const _TeamAllocationMatrix();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              border: Border(
                bottom: BorderSide(color: AppColors.outlineVariant),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Team Allocation Matrix',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text('Filter'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                    side: const BorderSide(color: AppColors.secondary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                AppColors.surfaceContainerLow,
              ),
              columns: const [
                DataColumn(
                  label: Text(
                    'ENGINEERING TEAM',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'CURRENT PROJECT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'ALLOCATION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'STATUS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'PERFORMANCE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
              rows: [
                _buildRow(
                  'Alpha Squad',
                  'Core Infrastructure V4',
                  0.85,
                  'On Track',
                  AppColors.greenBg,
                  AppColors.green,
                  '98%',
                ),
                _buildRow(
                  'Beta Frontend',
                  'UI Redesign Phase 2',
                  1.0,
                  'Overloaded',
                  AppColors.secondaryContainer.withValues(alpha: 0.2),
                  AppColors.secondary,
                  '82%',
                  isAlternate: true,
                ),
                _buildRow(
                  'Gamma Systems',
                  'Legacy Refactor',
                  0.45,
                  'Delayed',
                  AppColors.errorContainer,
                  AppColors.onErrorContainer,
                  '64%',
                ),
                _buildRow(
                  'Data Ops',
                  'ETL Optimization',
                  0.90,
                  'On Track',
                  AppColors.greenBg,
                  AppColors.green,
                  '91%',
                  isAlternate: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildRow(
    String team,
    String project,
    double allocation,
    String status,
    Color statusBg,
    Color statusColor,
    String performance, {
    bool isAlternate = false,
  }) {
    return DataRow(
      color: WidgetStateProperty.all(
        isAlternate ? Colors.white : Colors.transparent,
      ),
      cells: [
        DataCell(
          Text(
            team,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        DataCell(Text(project)),
        DataCell(
          SizedBox(
            width: 96,
            child: LinearProgressIndicator(
              value: allocation,
              backgroundColor: AppColors.surfaceContainer,
              color: AppColors.secondary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: statusColor,
              ),
            ),
          ),
        ),
        DataCell(
          Text(
            performance,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _NextDeployment extends StatelessWidget {
  const _NextDeployment();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Next Deployment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Scheduled for Tomorrow, 04:00 UTC',
                style: TextStyle(color: Color(0xFFB7C8DE)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer.withValues(
                        alpha: 0.2,
                      ),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'v2.4.1-rc',
                      style: TextStyle(fontSize: 12, color: Color(0xFFFFDDB9)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer.withValues(
                        alpha: 0.2,
                      ),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Critical',
                      style: TextStyle(fontSize: 12, color: Color(0xFFFFDDB9)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.rocket_launch,
              size: 120,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillDistribution extends StatelessWidget {
  const _SkillDistribution();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Skill Distribution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Icon(Icons.info, color: AppColors.onSurfaceVariant),
              ],
            ),
            const SizedBox(height: 16),
            _buildSkillBar('Backend / Distributed Systems', 0.42),
            const SizedBox(height: 16),
            _buildSkillBar('Frontend / UX Engineering', 0.28),
            const SizedBox(height: 16),
            _buildSkillBar('DevOps / Infrastructure', 0.18),
            const SizedBox(height: 16),
            _buildSkillBar('Data Science / ML Ops', 0.12),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillBar(String label, double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: AppColors.surfaceContainer,
          color: AppColors.primary,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }
}

class _CriticalEngineeringPath extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Critical Engineering Path',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Reviewing the next 4 sprint cycles across all squads.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'New Allocation Request',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 768;
                if (isWide) {
                  return Row(
                    children: const [
                      Expanded(
                        child: _PathCard(
                          icon: Icons.cloud_sync,
                          status: 'Active',
                          title: 'API Consolidation',
                          description:
                              'Merging legacy endpoints into the unified GraphQL gateway to reduce latency by 30%.',
                          avatars: 3,
                          plusCount: 3,
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: _PathCard(
                          icon: Icons.security,
                          status: 'At Risk',
                          title: 'Zero Trust Migration',
                          description:
                              'Implementing hardware-level security protocols for the remote workforce infrastructure.',
                          avatars: 2,
                          plusCount: 8,
                          isAtRisk: true,
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: _PathCard(
                          icon: Icons.storage,
                          status: 'Planning',
                          title: 'Data Mesh Protocol',
                          description:
                              'Architecture review for the new distributed data governance model across regions.',
                          avatars: 1,
                          plusCount: 2,
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: const [
                    _PathCard(
                      icon: Icons.cloud_sync,
                      status: 'Active',
                      title: 'API Consolidation',
                      description:
                          'Merging legacy endpoints into the unified GraphQL gateway to reduce latency by 30%.',
                      avatars: 3,
                      plusCount: 3,
                    ),
                    SizedBox(height: 24),
                    _PathCard(
                      icon: Icons.security,
                      status: 'At Risk',
                      title: 'Zero Trust Migration',
                      description:
                          'Implementing hardware-level security protocols for the remote workforce infrastructure.',
                      avatars: 2,
                      plusCount: 8,
                      isAtRisk: true,
                    ),
                    SizedBox(height: 24),
                    _PathCard(
                      icon: Icons.storage,
                      status: 'Planning',
                      title: 'Data Mesh Protocol',
                      description:
                          'Architecture review for the new distributed data governance model across regions.',
                      avatars: 1,
                      plusCount: 2,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  final IconData icon;
  final String status;
  final String title;
  final String description;
  final int avatars;
  final int plusCount;
  final bool isAtRisk;

  const _PathCard({
    required this.icon,
    required this.status,
    required this.title,
    required this.description,
    required this.avatars,
    required this.plusCount,
    this.isAtRisk = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.secondary),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isAtRisk
                      ? AppColors.error
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var i = 0; i < avatars; i++)
                Align(
                  widthFactor: 0.7,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFF1A2B3C),
                      child: const Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              Align(
                widthFactor: 0.7,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.surfaceContainerHighest,
                    child: Text(
                      '+$plusCount',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
