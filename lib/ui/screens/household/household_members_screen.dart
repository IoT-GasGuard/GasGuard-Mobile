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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildRegisteredMembers(),
                    const SizedBox(height: 30),
                    _buildNotificationSettings(),
                    const SizedBox(height: 80), // Espacio para el botón flotante
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMemberDialog,
        backgroundColor: const Color(0xFF4ECDC4),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Member'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people,
                color: Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Registered Members',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_members.isEmpty)
          _buildEmptyState()
        else
          ..._members.map((member) => MemberCard(
            member: member,
            onEdit: () => _showEditMemberDialog(member),
            onDelete: () => _showDeleteConfirmation(member),
          )),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.person_add_disabled,
            color: Colors.grey[600],
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No registered household members yet',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the "Add Member" button to register a new member',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active,
                  color: Color(0xFF4ECDC4),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Notification Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Gas Leak Alert Protocol',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'When gas levels exceed safety thresholds, the following actions will be taken:',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          _buildNotificationItem(
            title: 'Emergency contacts receive immediate SMS and email alerts',
          ),
          const SizedBox(height: 10),
          _buildNotificationItem(
            title: 'Emergency services as firefighters and 911 are notified',
          ),
          const SizedBox(height: 10),
          _buildNotificationItem(
            title: 'Opening of doors or windows for ventilation',
          ),
          const SizedBox(height: 10),
          _buildNotificationItem(
            title: 'Power supply shutoff for high levels of gas',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({required String title}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 5),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xFF4ECDC4),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
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