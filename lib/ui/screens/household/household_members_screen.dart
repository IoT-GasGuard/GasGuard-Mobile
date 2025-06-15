import 'package:flutter/material.dart';
import 'package:gasguard_mobile/models/household_member.dart';
import 'package:gasguard_mobile/utils/top_menu.dart';
import '../../common/app_header.dart';
import 'components/add_edit_member_dialog.dart';
import 'components/member_card.dart';
import 'components/search_filterBar.dart';

class HouseholdMembersScreen extends StatefulWidget {
  const HouseholdMembersScreen({Key? key}) : super(key: key);

  @override
  State<HouseholdMembersScreen> createState() => _HouseholdMembersScreenState();
}

class _HouseholdMembersScreenState extends State<HouseholdMembersScreen> with SingleTickerProviderStateMixin {
  final List<HouseholdMember> _allMembers = [
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

  late List<HouseholdMember> _filteredMembers;
  String _searchQuery = '';
  bool _showEmergencyOnly = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _filteredMembers = _allMembers;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _filterMembers() {
    setState(() {
      _filteredMembers = _allMembers
          .where((member) =>
      member.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          (!_showEmergencyOnly || member.isEmergencyContact))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2A),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: "Household Members",
              showBackButton: true,
              onBackPressed: () => Navigator.pop(context),
              onMenuPressed: () => TopMenu.showMenu(context),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2B3D),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Barra de búsqueda y filtro
                    SearchFilterBar(
                      onSearch: (query) {
                        _searchQuery = query;
                        _filterMembers();
                      },
                      onToggleEmergencyOnly: (value) {
                        _showEmergencyOnly = value;
                        _filterMembers();
                      },
                    ),

                    // Pestañas (All Members / Emergency Contacts)
                    TabBar(
                      controller: _tabController,
                      indicatorColor: const Color(0xFF4ECDC4),
                      indicatorWeight: 3,
                      labelColor: const Color(0xFF4ECDC4),
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(text: "All Members"),
                        Tab(text: "Emergency Contacts"),
                      ],
                    ),

                    // Contenido principal
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Tab 1: All Members
                          _buildMembersList(_filteredMembers),

                          // Tab 2: Emergency Contacts
                          _buildMembersList(_filteredMembers.where((m) => m.isEmergencyContact).toList()),
                        ],
                      ),
                    ),
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
        icon: const Icon(Icons.person_add),
        label: const Text('Add Member'),
        elevation: 4,
      ),
    );
  }

  Widget _buildMembersList(List<HouseholdMember> members) {
    if (members.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: members.length + 1,
      itemBuilder: (context, index) {
        if (index < members.length) {
          return AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
            child: MemberCard(
              member: members[index],
              onEdit: () => _showEditMemberDialog(members[index]),
              onDelete: () => _showDeleteConfirmation(members[index]),
            ),
          );
        } else {
          return _buildNotificationSettings();
        }
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add_disabled,
            color: Colors.grey[600],
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'No registered household members yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the "Add Member" button to register a new member',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF142D40), Color(0xFF0F1E2E)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF2D4055),
          width: 1.5,
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
                  color: const Color(0xFF4ECDC4).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF4ECDC4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Gas Leak Alerts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Safety measures during a gas leak:',
            style: TextStyle(
              color: Color(0xFF4ECDC4),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'When GasGuard detects a gas leak, the following actions are taken automatically:',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
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
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF4ECDC4),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4ECDC4).withOpacity(0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
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
            _allMembers.add(HouseholdMember(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              fullName: member.fullName,
              email: member.email,
              phoneNumber: member.phoneNumber,
              isEmergencyContact: member.isEmergencyContact,
              gasLeakAlerts: member.gasLeakAlerts,
              notificationsEnabled: member.notificationsEnabled,
            ));
            _filterMembers();
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
            final index = _allMembers.indexWhere((m) => m.id == member.id);
            if (index != -1) {
              _allMembers[index] = updatedMember;
            }
            _filterMembers();
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
                _allMembers.removeWhere((m) => m.id == member.id);
                _filterMembers();
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