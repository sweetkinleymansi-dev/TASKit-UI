import 'package:flutter/material.dart';

void main() {
  runApp(const TASKitApp());
}

class Task {
  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.date,
    this.time = '',
    this.reminder = false,
    this.completed = false,
    required this.created,
  });

  int id;
  String title;
  String description;
  String category;
  String priority;
  DateTime date;
  String time;
  bool reminder;
  bool completed;
  DateTime created;
}

class TASKitApp extends StatelessWidget {
  const TASKitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TASKit - Personal Task Manager',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F4ED),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6F3042)),
        fontFamily: 'Arial',
      ),
      home: const TASKitHome(),
    );
  }
}

class TASKitHome extends StatefulWidget {
  const TASKitHome({super.key});

  @override
  State<TASKitHome> createState() => _TASKitHomeState();
}

class _TASKitHomeState extends State<TASKitHome> {
  static const maroon = Color(0xFF6F3042);
  static const card = Color(0xFFFFFDF7);
  static const green = Color(0xFFDCE9DA);
  static const lightGreen = Color(0xFFE1EEE0);
  static const text = Color(0xFF27332D);
  static const muted = Color(0xFF89918B);

  final List<String> pages = const [
    'Dashboard',
    'Tasks',
    'Calendar',
    'Reminders',
    'History',
  ];

  late List<Task> tasks;

  int pageIndex = 0;
  String taskFilter = 'all';
  String search = '';
  String categoryFilter = 'all';
  String priorityFilter = 'all';

  DateTime selectedDate = DateTime.now();
  DateTime calendarMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    tasks = _demoTasks();
  }

  DateTime _dateOnly(DateTime d) {
    return DateTime(d.year, d.month, d.day);
  }

  List<Task> _demoTasks() {
    final now = DateTime.now();
    final today = _dateOnly(now);

    return [
      Task(
        id: 1,
        title: 'Submit IT1814 Lab Report',
        description: 'Finish and submit the laboratory report.',
        category: 'Academic',
        priority: 'High',
        date: today,
        time: '23:59',
        reminder: true,
        created: now,
      ),
      Task(
        id: 2,
        title: 'Take Vitamin D',
        description: 'Daily medicine reminder.',
        category: 'Health',
        priority: 'High',
        date: today,
        time: '10:00',
        reminder: true,
        created: now,
      ),
      Task(
        id: 3,
        title: 'Group Project Meeting',
        description: 'Discuss project progress with the group.',
        category: 'Academic',
        priority: 'Medium',
        date: today,
        time: '14:00',
        reminder: true,
        created: now,
      ),
      Task(
        id: 4,
        title: 'Buy Groceries',
        description: 'Weekly grocery shopping.',
        category: 'Personal',
        priority: 'Low',
        date: today.add(const Duration(days: 1)),
        time: '18:00',
        created: now,
      ),
      Task(
        id: 5,
        title: 'Read OOP Chapter',
        description: 'Read the assigned OOP chapter.',
        category: 'Academic',
        priority: 'Medium',
        date: today.subtract(const Duration(days: 2)),
        time: '19:00',
        completed: true,
        created: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _formatLongDate(DateTime d) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${weekdays[d.weekday - 1]}, '
        '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _formatTime(String time) {
    if (time.isEmpty) return 'Any time';

    final parts = time.split(':');

    if (parts.length != 2) {
      return time;
    }

    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;

    final suffix = h >= 12 ? 'PM' : 'AM';
    final hour = h % 12 == 0 ? 12 : h % 12;

    return '$hour:${m.toString().padLeft(2, '0')} $suffix';
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');

    return TimeOfDay(
      hour: parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
  }

  int _priorityWeight(String p) {
    if (p == 'High') return 3;
    if (p == 'Medium') return 2;
    return 1;
  }

  void _sortByDateTime(List<Task> list) {
    list.sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);

      if (dateCompare != 0) {
        return dateCompare;
      }

      final timeA = a.time.isEmpty ? '99:99' : a.time;
      final timeB = b.time.isEmpty ? '99:99' : b.time;

      return timeA.compareTo(timeB);
    });
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  void _goTo(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  int get todayCount {
    final today = _dateOnly(DateTime.now());

    return tasks
        .where((t) => _dateOnly(t.date) == today && !t.completed)
        .length;
  }

  int get highCount {
    return tasks.where((t) => t.priority == 'High' && !t.completed).length;
  }

  int get completedCount {
    return tasks.where((t) => t.completed).length;
  }

  int get upcomingCount {
    final today = _dateOnly(DateTime.now());

    return tasks
        .where((t) => !t.completed && !_dateOnly(t.date).isBefore(today))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 620;
        final tablet = constraints.maxWidth < 900;

        return Scaffold(
          drawer: mobile ? _buildDrawer() : null,
          body: Row(
            children: [
              if (!mobile) _buildSidebar(tablet),
              Expanded(child: _buildMain(mobile, tablet)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(child: _buildSidebar(false, inDrawer: true));
  }

  Widget _buildSidebar(bool compact, {bool inDrawer = false}) {
    return Container(
      width: compact ? 74 : 245,
      color: card,
      padding: EdgeInsets.fromLTRB(
        compact ? 10 : 16,
        24,
        compact ? 10 : 16,
        18,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: maroon,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 22),
              ),
              if (!compact) ...[
                const SizedBox(width: 11),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TASKit',
                        style: TextStyle(
                          color: maroon,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Plan. Organize. Accomplish.',
                        style: TextStyle(
                          color: Color(0xFF849087),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 30),
          ...List.generate(pages.length, (i) => _navItem(i, compact)),
          const Spacer(),
          _navButton(
            Icons.person_outline,
            'Profile',
            () => _toast('Profile settings can be added here.'),
            compact,
          ),
          _navButton(
            Icons.delete_outline,
            'Clear demo data',
            _clearData,
            compact,
          ),
        ],
      ),
    );
  }

  Widget _navItem(int index, bool compact) {
    final icons = [
      Icons.dashboard_outlined,
      Icons.checklist_outlined,
      Icons.calendar_month_outlined,
      Icons.notifications_none,
      Icons.history,
    ];

    return _navButton(
      icons[index],
      pages[index],
      () => _goTo(index),
      compact,
      active: pageIndex == index,
    );
  }

  Widget _navButton(
    IconData icon,
    String label,
    VoidCallback onTap,
    bool compact, {
    bool active = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Material(
        color: active ? lightGreen : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: active ? maroon : const Color(0xFF69746D),
                ),
                if (!compact) ...[
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: active ? maroon : const Color(0xFF69746D),
                        fontWeight: active
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMain(bool mobile, bool tablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        mobile
            ? 13
            : tablet
            ? 22
            : 42,
        20,
        mobile
            ? 13
            : tablet
            ? 22
            : 42,
        50,
      ),
      child: Column(children: [_buildTopbar(mobile), _buildPage()]),
    );
  }

  Widget _buildTopbar(bool mobile) {
    final title = pages[pageIndex];

    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Row(
        children: [
          if (mobile)
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatLongDate(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8B938D),
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: maroon,
                    fontSize: mobile ? 24 : 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _goTo(3),
            icon: Badge(
              isLabelVisible: tasks.any(
                (t) =>
                    t.reminder &&
                    !t.completed &&
                    _dateOnly(t.date) == _dateOnly(DateTime.now()),
              ),
              child: const Icon(Icons.notifications_none, color: maroon),
            ),
          ),
          const SizedBox(width: 5),
          const CircleAvatar(
            radius: 21,
            backgroundColor: green,
            child: Text(
              'M',
              style: TextStyle(color: maroon, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage() {
    switch (pageIndex) {
      case 1:
        return _tasksPage();
      case 2:
        return _calendarPage();
      case 3:
        return _remindersPage();
      case 4:
        return _historyPage();
      default:
        return _dashboardPage();
    }
  }

  Widget _dashboardPage() {
    final today = _dateOnly(DateTime.now());

    final todayTasks = tasks.where((t) => _dateOnly(t.date) == today).toList();

    _sortByDateTime(todayTasks);

    final priority = tasks.where((t) => !t.completed).toList()
      ..sort((a, b) {
        final priorityCompare = _priorityWeight(b.priority)
            .compareTo(_priorityWeight(a.priority));

        if (priorityCompare != 0) {
          return priorityCompare;
        }

        return a.date.compareTo(b.date);
      });

    return Column(
      children: [
        _welcomeCard(),
        _statsGrid(),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 800) {
              return Column(
                children: [
                  _schedulePanel(todayTasks),
                  _priorityPanel(priority),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _schedulePanel(todayTasks)),
                const SizedBox(width: 18),
                Expanded(flex: 4, child: _priorityPanel(priority)),
              ],
            );
          },
        ),
        _quickActions(),
      ],
    );
  }

  Widget _welcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: green,
        borderRadius: BorderRadius.circular(24),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mobile = constraints.maxWidth < 500;

          if (mobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: maroon,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 15),
                const Text(
                  'WELCOME BACK',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Color(0xFF61756A),
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Stay organized, one task at a time.',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: text,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Keep track of your daily activities, deadlines, '
                  'and reminders in one place.',
                  style: TextStyle(
                    color: Color(0xFF667269),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            );
          }

          return Row(
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: maroon,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 18),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WELCOME BACK',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Color(0xFF61756A),
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'Stay organized, one task at a time.',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: text,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'Keep track of your daily activities, deadlines, '
                      'and reminders in one place.',
                      style: TextStyle(
                        color: Color(0xFF667269),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 500 ? 2 : 4;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          childAspectRatio: constraints.maxWidth < 500 ? 1.8 : 2.2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _statCard('Today’s Tasks', todayCount, Icons.today_outlined),
            _statCard('High Priority', highCount, Icons.priority_high),
            _statCard('Completed', completedCount, Icons.check_circle_outline),
            _statCard('Upcoming', upcomingCount, Icons.event_outlined),
          ],
        );
      },
    );
  }

  Widget _statCard(String label, int value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _box(),
      child: Row(
        children: [
          Icon(icon, color: maroon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF858C87),
                    fontSize: 12,
                  ),
                ),
                Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 28,
                    color: maroon,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _box() {
    return BoxDecoration(
      color: card,
      border: Border.all(color: const Color(0xFFE8E3D8)),
      borderRadius: BorderRadius.circular(18),
    );
  }

  Widget _panel(
    String title,
    Widget child, {
    String? action,
    VoidCallback? onAction,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (action != null)
                TextButton(
                  onPressed: onAction,
                  child: Text(
                    action,
                    style: const TextStyle(
                      color: maroon,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          child,
        ],
      ),
    );
  }

  Widget _schedulePanel(List<Task> list) {
    return _panel(
      'Today’s Schedule',
      list.isEmpty
          ? _empty('No activities scheduled for today.')
          : Column(children: list.map(_scheduleItem).toList()),
      action: 'View calendar',
      onAction: () => _goTo(2),
    );
  }

  Widget _priorityPanel(List<Task> list) {
    return _panel(
      'Priority Tasks',
      list.isEmpty
          ? _empty('No pending priority tasks.')
          : Column(children: list.take(4).map(_taskItem).toList()),
      action: 'View all',
      onAction: () => _goTo(1),
    );
  }

  Widget _scheduleItem(Task t) {
    final icon = t.category == 'Health'
        ? Icons.medication_outlined
        : t.category == 'Academic'
        ? Icons.school_outlined
        : Icons.check;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F3),
        border: Border.all(color: const Color(0xFFE8E4DA)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F0E5),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: maroon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${t.category} • ${_formatTime(t.time)}',
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
          ),
          _priorityBadge(t.priority),
        ],
      ),
    );
  }

  Widget _priorityBadge(String p) {
    final bg = p == 'High'
        ? const Color(0xFFF8DDDD)
        : p == 'Medium'
        ? const Color(0xFFFAE9C7)
        : const Color(0xFFDCEBDC);

    final fg = p == 'High'
        ? const Color(0xFFA43E46)
        : p == 'Medium'
        ? const Color(0xFF9B6815)
        : const Color(0xFF4E7654);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        p,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _taskItem(Task t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F3),
        border: Border.all(color: const Color(0xFFE8E4DA)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Checkbox(
            value: t.completed,
            onChanged: (_) => _toggleTask(t),
            activeColor: maroon,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: t.completed ? TextDecoration.lineThrough : null,
                    color: t.completed ? const Color(0xFF969C97) : text,
                  ),
                ),
                Text(
                  '${_formatDate(t.date)}'
                  '${t.time.isNotEmpty ? ' • ${_formatTime(t.time)}' : ''}',
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 5),
                _categoryChip(t.category),
              ],
            ),
          ),
          _priorityBadge(t.priority),
        ],
      ),
    );
  }

  Widget _categoryChip(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE7EEE5),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 10, color: Color(0xFF59705F)),
      ),
    );
  }

  Widget _empty(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD9D6CD)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: muted),
      ),
    );
  }

  Widget _quickActions() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 500 ? 1 : 3;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: constraints.maxWidth < 500 ? 4.0 : 2.2,
          children: [
            _quickCard(
              Icons.add_task,
              'Add Task',
              'Create a new task',
              _openTaskDialog,
            ),
            _quickCard(
              Icons.calendar_month,
              'Calendar',
              'View your schedule',
              () => _goTo(2),
            ),
            _quickCard(
              Icons.notifications_none,
              'Reminders',
              'Manage reminders',
              () => _goTo(3),
            ),
          ],
        );
      },
    );
  }

  Widget _quickCard(IconData icon, String title, String sub, VoidCallback tap) {
    return InkWell(
      onTap: tap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: _box(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: maroon, size: 22),
            const SizedBox(height: 7),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(sub, style: const TextStyle(color: muted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _tasksPage() {
    final list = tasks.where((t) {
      final state =
          taskFilter == 'all' ||
          (taskFilter == 'completed' ? t.completed : !t.completed);

      final q = search.toLowerCase();

      return state &&
          (categoryFilter == 'all' || t.category == categoryFilter) &&
          (priorityFilter == 'all' || t.priority == priorityFilter) &&
          (t.title.toLowerCase().contains(q) ||
              t.description.toLowerCase().contains(q));
    }).toList();

    list.sort((a, b) {
      final completedA = a.completed ? 1 : 0;
      final completedB = b.completed ? 1 : 0;

      if (completedA != completedB) {
        return completedA.compareTo(completedB);
      }

      return a.date.compareTo(b.date);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 500) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _filterButton('all', 'All'),
                      _filterButton('todo', 'To Do'),
                      _filterButton('completed', 'Completed'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _openTaskDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Task'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: maroon,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  spacing: 7,
                  children: [
                    _filterButton('all', 'All'),
                    _filterButton('todo', 'To Do'),
                    _filterButton('completed', 'Completed'),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _openTaskDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Task'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroon,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 15),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 650) {
              return Column(
                children: [
                  _searchBox(),
                  const SizedBox(height: 10),
                  _dropdown(
                    'Category',
                    categoryFilter,
                    ['all', 'Academic', 'Personal', 'Health'],
                    (value) {
                      setState(() {
                        categoryFilter = value ?? 'all';
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  _dropdown(
                    'Priority',
                    priorityFilter,
                    ['all', 'High', 'Medium', 'Low'],
                    (value) {
                      setState(() {
                        priorityFilter = value ?? 'all';
                      });
                    },
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: _searchBox()),
                const SizedBox(width: 10),
                SizedBox(
                  width: 190,
                  child: _dropdown(
                    'Category',
                    categoryFilter,
                    ['all', 'Academic', 'Personal', 'Health'],
                    (value) {
                      setState(() {
                        categoryFilter = value ?? 'all';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 170,
                  child: _dropdown(
                    'Priority',
                    priorityFilter,
                    ['all', 'High', 'Medium', 'Low'],
                    (value) {
                      setState(() {
                        priorityFilter = value ?? 'all';
                      });
                    },
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 15),
        if (list.isEmpty)
          _empty('No tasks match your filters.')
        else
          Column(children: list.map(_fullTaskItem).toList()),
      ],
    );
  }

  Widget _filterButton(String value, String label) {
    return TextButton(
      onPressed: () {
        setState(() {
          taskFilter = value;
        });
      },
      style: TextButton.styleFrom(
        backgroundColor: taskFilter == value ? maroon : card,
        foregroundColor: taskFilter == value ? Colors.white : text,
        side: const BorderSide(color: Color(0xFFDDD9CF)),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
      child: Text(label),
    );
  }

  Widget _searchBox() {
    return TextField(
      onChanged: (value) {
        setState(() {
          search = value;
        });
      },
      decoration: const InputDecoration(
        hintText: 'Search tasks...',
        prefixIcon: Icon(Icons.search),
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Color(0xFFDDD9CF)),
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: card,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Color(0xFFDDD9CF)),
        ),
      ),
      items: options.map((x) {
        return DropdownMenuItem<String>(
          value: x,
          child: Text(x == 'all' ? 'All ${label}s' : x),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _fullTaskItem(Task t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: _box(),
      child: Row(
        children: [
          Checkbox(
            value: t.completed,
            onChanged: (_) => _toggleTask(t),
            activeColor: maroon,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: t.completed ? TextDecoration.lineThrough : null,
                    color: t.completed ? const Color(0xFF969C97) : text,
                  ),
                ),
                Text(
                  '${_formatDate(t.date)}'
                  '${t.time.isNotEmpty ? ' • ${_formatTime(t.time)}' : ''}',
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 6),
                _categoryChip(t.category),
              ],
            ),
          ),
          _priorityBadge(t.priority),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _openTaskDialog(task: t);
              }

              if (value == 'delete') {
                _deleteTask(t);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calendarPage() {
    final selectedTasks =
        tasks
            .where((t) => _dateOnly(t.date) == _dateOnly(selectedDate))
            .toList()
          ..sort((a, b) => a.time.compareTo(b.time));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  calendarMonth = DateTime(
                    calendarMonth.year,
                    calendarMonth.month - 1,
                  );
                });
              },
              icon: const Icon(Icons.chevron_left),
            ),
            SizedBox(
              width: 190,
              child: Text(
                '${_monthName(calendarMonth.month)} '
                '${calendarMonth.year}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  calendarMonth = DateTime(
                    calendarMonth.year,
                    calendarMonth.month + 1,
                  );
                });
              },
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: _box(),
          child: _calendarGrid(),
        ),
        const SizedBox(height: 18),
        _panel(
          'Activities — ${_formatDate(selectedDate)}',
          selectedTasks.isEmpty
              ? _empty('No activities for this date.')
              : Column(children: selectedTasks.map(_scheduleItem).toList()),
          action: 'Add',
          onAction: _openTaskDialog,
        ),
      ],
    );
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }

  Widget _calendarGrid() {
    final first = DateTime(calendarMonth.year, calendarMonth.month, 1);

    final start = first.subtract(Duration(days: first.weekday % 7));

    return Column(
      children: [
        Row(
          children: const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
              .map(
                (day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 7),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 42,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemBuilder: (context, index) {
            final day = start.add(Duration(days: index));

            final count = tasks
                .where((task) => _dateOnly(task.date) == _dateOnly(day))
                .length;

            final otherMonth = day.month != calendarMonth.month;

            final today = _dateOnly(day) == _dateOnly(DateTime.now());

            final selected = _dateOnly(day) == _dateOnly(selectedDate);

            return InkWell(
              onTap: () {
                setState(() {
                  selectedDate = _dateOnly(day);
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: selected ? lightGreen : card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: today ? maroon : const Color(0xFFECE8DF),
                    width: today ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        color: otherMonth ? const Color(0xFFB5B9B5) : text,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    if (count > 0)
                      Row(
                        children: List.generate(
                          count > 3 ? 3 : count,
                          (_) => Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.only(right: 3),
                            decoration: const BoxDecoration(
                              color: maroon,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _remindersPage() {
    final list =
        tasks.where((task) => task.reminder && !task.completed).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(23),
          decoration: BoxDecoration(
            color: green,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reminders & Notifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Keep track of important activities '
                'and reminders.',
                style: TextStyle(color: Color(0xFF667269)),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () {
                  _toast(
                    'Flutter notifications can be connected '
                    'with flutter_local_notifications.',
                  );
                },
                icon: const Icon(Icons.notifications_active_outlined),
                label: const Text('Enable notifications'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: maroon,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (list.isEmpty)
          _empty('No active reminders.')
        else
          Column(
            children: list.map((task) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: _box(),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F0E5),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        task.category == 'Health'
                            ? Icons.medication_outlined
                            : Icons.notifications_none,
                        color: maroon,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_formatDate(task.date)} • '
                            '${_formatTime(task.time)} • '
                            '${task.category}',
                            style: const TextStyle(color: muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _toggleReminder(task),
                      icon: const Icon(Icons.check),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _historyPage() {
    final done = tasks.where((task) => task.completed).toList()
      ..sort((a, b) => b.created.compareTo(a.created));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < 500 ? 1 : 3;

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: columns == 1 ? 4 : 2.2,
              children: [
                _historyCard('Completed Tasks', done.length),
                _historyCard(
                  'Academic',
                  done.where((task) => task.category == 'Academic').length,
                ),
                _historyCard(
                  'Personal',
                  done.where((task) => task.category == 'Personal').length,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        if (done.isEmpty)
          _empty('No completed tasks yet.')
        else
          Column(
            children: done.map((task) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: _box(),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F0E5),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(Icons.check, color: maroon),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Completed • '
                            '${_formatDate(task.date)} • '
                            '${task.category}',
                            style: const TextStyle(color: muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    _categoryChip(task.category),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _historyCard(String label, int value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF858C87), fontSize: 12),
          ),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 30,
              color: maroon,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleTask(Task t) {
    setState(() {
      t.completed = !t.completed;
    });

    _toast(t.completed ? 'Task completed!' : 'Task moved back to To Do.');
  }

  void _toggleReminder(Task t) {
    setState(() {
      t.reminder = false;
    });

    _toast('Reminder turned off.');
  }

  void _deleteTask(Task t) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete this task?'),
          content: Text('Delete “${t.title}”?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  tasks.remove(t);
                });

                Navigator.pop(dialogContext);
                _toast('Task deleted.');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: maroon,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _clearData() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear all tasks?'),
          content: const Text('This will restore the demo tasks.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  tasks = _demoTasks();
                });

                Navigator.pop(dialogContext);
                _toast('Demo data restored.');
              },
              child: const Text('Restore'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openTaskDialog({Task? task}) async {
    final titleController = TextEditingController(text: task?.title ?? '');

    final descriptionController = TextEditingController(
      text: task?.description ?? '',
    );

    String category = task?.category ?? 'Academic';

    String priority = task?.priority ?? 'Medium';

    DateTime date = task?.date ?? selectedDate;

    TimeOfDay? time = task?.time.isNotEmpty == true
        ? _parseTime(task!.time)
        : null;

    bool reminder = task?.reminder ?? false;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    task == null ? 'Add Task' : 'Edit Task',
                    style: const TextStyle(color: maroon),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Task title *',
                      ),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: ['Academic', 'Personal', 'Health'].map((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            category = value;
                          });
                        }
                      },
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: priority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: ['High', 'Medium', 'Low'].map((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            priority = value;
                          });
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Due date *'),
                      subtitle: Text(_formatDate(date)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          initialDate: date,
                        );

                        if (picked != null) {
                          setModalState(() {
                            date = picked;
                          });
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Time'),
                      subtitle: Text(
                        time == null ? 'Any time' : time!.format(context),
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: time ?? TimeOfDay.now(),
                        );

                        if (picked != null) {
                          setModalState(() {
                            time = picked;
                          });
                        }
                      },
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: reminder,
                      onChanged: (value) {
                        setModalState(() {
                          reminder = value ?? false;
                        });
                      },
                      title: const Text('Set a reminder'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      return;
                    }

                    final timeString = time == null
                        ? ''
                        : '${time!.hour.toString().padLeft(2, '0')}:'
                              '${time!.minute.toString().padLeft(2, '0')}';

                    setState(() {
                      if (task == null) {
                        tasks.add(
                          Task(
                            id: DateTime.now().microsecondsSinceEpoch,
                            title: titleController.text.trim(),
                            description: descriptionController.text.trim(),
                            category: category,
                            priority: priority,
                            date: date,
                            time: timeString,
                            reminder: reminder,
                            created: DateTime.now(),
                          ),
                        );
                      } else {
                        task.title = titleController.text.trim();

                        task.description = descriptionController.text.trim();

                        task.category = category;

                        task.priority = priority;

                        task.date = date;
                        task.time = timeString;
                        task.reminder = reminder;
                      }
                    });

                    Navigator.pop(dialogContext, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroon,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(task == null ? 'Save Task' : 'Update Task'),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved == true) {
      _toast(task == null ? 'Task added.' : 'Task updated.');
    }

    titleController.dispose();
    descriptionController.dispose();
  }
}
