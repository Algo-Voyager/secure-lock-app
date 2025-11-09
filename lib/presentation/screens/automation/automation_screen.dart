import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/automation_provider.dart';
import '../../../data/models/automation_rule_model.dart';

class AutomationScreen extends StatefulWidget {
  const AutomationScreen({super.key});

  @override
  State<AutomationScreen> createState() => _AutomationScreenState();
}

class _AutomationScreenState extends State<AutomationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AutomationProvider>().loadRules();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Automation Rules'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
            tooltip: 'Info',
          ),
        ],
      ),
      body: Consumer<AutomationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.rules.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadRules(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary card
                _buildSummaryCard(provider),
                const SizedBox(height: 20),

                // Rules by type
                _buildRuleSection(
                  context,
                  'Location-Based Rules',
                  'location',
                  Icons.location_on,
                  Colors.blue,
                  provider,
                ),
                _buildRuleSection(
                  context,
                  'Time-Based Rules',
                  'time',
                  Icons.access_time,
                  Colors.orange,
                  provider,
                ),
                _buildRuleSection(
                  context,
                  'WiFi-Based Rules',
                  'wifi',
                  Icons.wifi,
                  Colors.green,
                  provider,
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRuleDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Rule'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rule,
            size: 100,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Automation Rules',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create rules to automatically lock/unlock\napps based on location, time, or WiFi',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddRuleDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Create First Rule'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(AutomationProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total Rules',
                  provider.ruleCount.toString(),
                  Icons.rule,
                  Colors.blue,
                ),
                _buildStatItem(
                  'Active',
                  provider.enabledRuleCount.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatItem(
                  'Inactive',
                  (provider.ruleCount - provider.enabledRuleCount).toString(),
                  Icons.cancel,
                  Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRuleSection(
    BuildContext context,
    String title,
    String ruleType,
    IconData icon,
    Color color,
    AutomationProvider provider,
  ) {
    final rules = provider.getRulesByType(ruleType);

    if (rules.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${rules.length} ${rules.length == 1 ? 'rule' : 'rules'}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...rules.map((rule) => _buildRuleCard(context, rule, provider, color)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRuleCard(
    BuildContext context,
    AutomationRuleModel rule,
    AutomationProvider provider,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(
            _getIconForRuleType(rule.ruleType),
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          rule.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(_getRuleDescription(rule)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: rule.isEnabled,
              onChanged: (value) => provider.toggleRuleEnabled(rule.id),
              activeColor: color,
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteRule(context, rule, provider);
                } else if (value == 'edit') {
                  _editRule(context, rule);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForRuleType(String type) {
    switch (type) {
      case 'location':
        return Icons.location_on;
      case 'time':
        return Icons.access_time;
      case 'wifi':
        return Icons.wifi;
      default:
        return Icons.rule;
    }
  }

  String _getRuleDescription(AutomationRuleModel rule) {
    switch (rule.ruleType) {
      case 'location':
        return '${rule.locationName ?? 'Unknown location'} (${rule.radiusMeters?.toInt() ?? 0}m)';
      case 'time':
        return '${rule.startTime ?? '00:00'} - ${rule.endTime ?? '23:59'}';
      case 'wifi':
        return rule.wifiSSID ?? 'Unknown WiFi';
      default:
        return 'No description';
    }
  }

  void _showAddRuleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Rule Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.blue),
              title: const Text('Location-Based'),
              subtitle: const Text('Auto unlock at specific locations'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to location rule screen
                _showComingSoon(context, 'Location rules');
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time, color: Colors.orange),
              title: const Text('Time-Based'),
              subtitle: const Text('Auto unlock during specific times'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to time rule screen
                _showComingSoon(context, 'Time rules');
              },
            ),
            ListTile(
              leading: const Icon(Icons.wifi, color: Colors.green),
              title: const Text('WiFi-Based'),
              subtitle: const Text('Auto unlock on trusted WiFi'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to WiFi rule screen
                _showComingSoon(context, 'WiFi rules');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editRule(BuildContext context, AutomationRuleModel rule) {
    _showComingSoon(context, 'Edit rule');
  }

  void _deleteRule(
    BuildContext context,
    AutomationRuleModel rule,
    AutomationProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Rule'),
        content: Text('Are you sure you want to delete "${rule.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.deleteRule(rule.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Rule deleted' : 'Failed to delete rule',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Automation'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Automation rules allow you to automatically lock or unlock apps based on:',
              ),
              SizedBox(height: 12),
              Text('📍 Location: Unlock when you\'re at home, work, etc.'),
              SizedBox(height: 8),
              Text('⏰ Time: Lock social apps during work hours'),
              SizedBox(height: 8),
              Text('📶 WiFi: Unlock when connected to trusted networks'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon!')),
    );
  }
}
