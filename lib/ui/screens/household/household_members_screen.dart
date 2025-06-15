import 'package:flutter/material.dart';
import 'package:gasguard_mobile/models/household_member.dart';
import 'package:gasguard_mobile/utils/top_menu.dart';

import '../../common/app_header.dart';
import 'components/add_edit_member_dialog.dart';
import 'components/member_card.dart';

class HouseholdMembersScreen extends StatefulWidget {
  const HouseholdMembersScreen({Key? key}) : super(key: key);

  @override
  State<HouseholdMembersScreen> createState() => _HouseholdMembersScreenState();
}

class _HouseholdMembersScreenState extends State<HouseholdMembersScreen> {
  final List<HouseholdMember> _members = [
    HouseholdMember(
      id: '1',
      fullName: 'Jair Velasquez',
      email: 'jair.velasquez@gmail.com',
      phoneNumber: '+51 945 343 538',
      isEmergencyContact: true,
      gasLeakAlerts: true,
      notificationsEnabled: true,
    ),
    HouseholdMember(
      id: '2',
      fullName: 'Karlahen Centeno',
      email: 'karlahen.centeno@gmail.com',
      phoneNumber: '+51 945 343 538',
      isEmergencyContact: false,
      gasLeakAlerts: true,
      notificationsEnabled: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1A2B3D),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Household Members',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildRegisteredMembers(),
                            const SizedBox(height: 30),
                            _buildNotificationSettings(),
                          ],
                        ),
                      ),
                    ),
                    _buildAddMemberButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AppHeader(
      title: "Household Members",
      showBackButton: true,
      onBackPressed: () => Navigator.pop(context),
      onMenuPressed: () => TopMenu.showMenu(context),
    );
  }

  Widget _buildRegisteredMembers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Registered Members',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._members.map((member) => MemberCard(
          member: member,
          onEdit: () => _showEditMemberDialog(member),
          onDelete: () => _showDeleteConfirmation(member),
        )),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1B2A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF2A3B4D),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notification Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildNotificationItem(
            title: 'Gas Leak Alert Protocol',
            subtitle: 'When gas levels exceed safety thresholds, all registered members receive alerts',
          ),
          const SizedBox(height: 12),
          _buildNotificationItem(
            title: 'Emergency contacts receive immediate SMS and email alerts',
            subtitle: '',
          ),
          const SizedBox(height: 12),
          _buildNotificationItem(
            title: 'Emergency services as firefighters will be notified',
            subtitle: '',
          ),
          const SizedBox(height: 12),
          _buildNotificationItem(
            title: 'Power supply shutoff for ventilation',
            subtitle: '',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({required String title, required String subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xFF4ECDC4),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddMemberButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _showAddMemberDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4ECDC4),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          icon: const Icon(Icons.add),
          label: const Text(
            'Add Member',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEditMemberDialog(
        title: 'Add Member',
        onSave: (member) {
          setState(() {
            _members.add(member.copyWith(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
            ));
          });
          Navigator.pop(context);
          _showSuccessSnackBar('Member added successfully');
        },
      ),
    );
  }

  void _showEditMemberDialog(HouseholdMember member) {
    showDialog(
      context: context,
      builder: (context) => AddEditMemberDialog(
        title: 'Edit Member',
        member: member,
        onSave: (updatedMember) {
          setState(() {
            final index = _members.indexWhere((m) => m.id == member.id);
            if (index != -1) {
              _members[index] = updatedMember;
            }
          });
          Navigator.pop(context);
          _showSuccessSnackBar('Member updated successfully');
        },
      ),
    );
  }

  void _showDeleteConfirmation(HouseholdMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2B3D),
        title: const Text(
          'Delete Member',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to remove ${member.fullName} from household members?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _members.removeWhere((m) => m.id == member.id);
              });
              Navigator.pop(context);
              _showSuccessSnackBar('Member removed successfully');
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4ECDC4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}