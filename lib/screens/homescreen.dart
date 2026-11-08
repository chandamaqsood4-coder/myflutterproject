
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:thinkcodes/database/DatabaseHelper%20.dart';
import 'package:thinkcodes/model/takmodel.dart';
import 'package:thinkcodes/screens/taskdetailscreen.dart';
final hello = Provider<String>((ref){
return 'subscribers';
}); 
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ================= CONTROLLERS =================

  final TextEditingController taskController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final FocusNode taskFocusNode = FocusNode();

  // ================= TASKS =================

  final List<Task> tasks = [];

  final List<String> categories = ['All', 'Personal', 'Work', 'Study'];

  String selectedCategory = 'All';

  bool isLoading = true;
  bool isAddingTask = false;

  Timer? reminderTimer;

  final Set<int> alertedTaskIds = {};

  // ================= INITIAL STATE =================

  @override
  void initState() {
    super.initState();

    loadTasks();

    reminderTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => checkReminders(),
    );
  }

  // ================= LOAD TASKS FROM DATABASE =================

  Future<void> loadTasks() async {
    try {
      debugPrint('Loading tasks from database...');

      final List<Map<String, dynamic>> data = await DatabaseHelper.instance
          .getTasks();

      debugPrint('DATABASE DATA: $data');

      final List<Task> loadedTasks = data
          .map((item) => Task.fromMap(item))
          .toList();

      debugPrint('FETCHED TASK COUNT: ${loadedTasks.length}');

      if (!mounted) return;

      setState(() {
        tasks
          ..clear()
          ..addAll(loadedTasks);

        isLoading = false;
      });

      checkReminders();
    } catch (e, stackTrace) {
      debugPrint('LOAD DATABASE ERROR: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load tasks: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  // ================= ADD TASK =================

  Future<void> addTask() async {
    if (isAddingTask) return;

    final String title = taskController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a task')));
      return;
    }

    setState(() {
      isAddingTask = true;
    });

    try {
      final int insertedId = await DatabaseHelper.instance.insertTask({
        'title': title,
        'description': '',
        'category': selectedCategory == 'All' ? 'Personal' : selectedCategory,
        'completed': 0,
        'dueDate': null,
        'reminder': 0,
      });

      debugPrint('INSERTED TASK ID: $insertedId');

      taskController.clear();
      taskFocusNode.unfocus();

      await loadTasks();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task added successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('ADD DATABASE ERROR: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to add task: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isAddingTask = false;
        });
      }
    }
  }

  // ================= DELETE TASK =================

  Future<void> deleteTask(Task task) async {
    if (task.id == null) {
      debugPrint('DELETE ERROR: Task ID is null');
      return;
    }

    try {
      await DatabaseHelper.instance.deleteTask(task.id!);

      alertedTaskIds.remove(task.id);

      await loadTasks();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task deleted successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('DELETE DATABASE ERROR: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to delete task: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================= COMPLETE / UNCOMPLETE TASK =================

  Future<void> toggleTask(Task task, bool? value) async {
    if (task.id == null) {
      debugPrint('UPDATE ERROR: Task ID is null');
      return;
    }

    final bool oldValue = task.completed;

    setState(() {
      task.completed = value ?? false;
    });

    try {
      await DatabaseHelper.instance.updateTask(task.id!, task.toMap());

      await loadTasks();
    } catch (e, stackTrace) {
      debugPrint('UPDATE DATABASE ERROR: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        task.completed = oldValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to update task: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================= EDIT TASK =================

  Future<void> editTask(Task task) async {
    FocusScope.of(context).unfocus();

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailsScreen(task: task)),
    );

    if (!mounted) return;

    await loadTasks();
  }

  // ================= REMINDERS =================

  void checkReminders() {
    if (!mounted) return;

    final DateTime now = DateTime.now();

    for (final task in tasks) {
      if (task.id == null) continue;

      if (task.reminder &&
          !task.completed &&
          task.dueDate != null &&
          !task.dueDate!.isAfter(now) &&
          !alertedTaskIds.contains(task.id)) {
        alertedTaskIds.add(task.id!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder: ${task.title}'),
            backgroundColor: Colors.deepPurple,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // ================= FILTER TASKS =================

  List<Task> get filteredTasks {
    final String query = searchController.text.trim().toLowerCase();

    return tasks.where((task) {
      final bool matchesCategory =
          selectedCategory == 'All' || task.category == selectedCategory;

      final bool matchesSearch =
          task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  // ================= DATE FORMAT =================

  String formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String hour = date.hour.toString().padLeft(2, '0');
    final String minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year}  $hour:$minute';
  }

  // ================= DISPOSE =================

  @override
  void dispose() {
    reminderTimer?.cancel();

    taskController.dispose();
    searchController.dispose();
    taskFocusNode.dispose();

    super.dispose();
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    final int completedTasks = tasks.where((task) => task.completed).length;

    final double progress = tasks.isEmpty ? 0.0 : completedTasks / tasks.length;

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),
      resizeToAvoidBottomInset: true,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My To-Do List',
          style: TextStyle(
            color: Color(0xff242424),
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: checkReminders,
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),

      // ================= BODY =================
      body: SafeArea(
        child: Column(
          children: [
            // ================= SEARCH BAR =================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: TextField(
                controller: searchController,
                keyboardType: TextInputType.text,
                onChanged: (_) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Search your tasks...',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.deepPurple,
                  ),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // ================= PROGRESS CARD =================
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff673AB7), Color(0xff9575CD)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Your Progress',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    '$completedTasks of ${tasks.length} tasks completed',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),

                  const SizedBox(height: 14),

                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 9,
                    borderRadius: BorderRadius.circular(10),
                    backgroundColor: Colors.white30,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${(progress * 100).toInt()}% Completed',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ================= CATEGORY TABS =================
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final String category = categories[index];

                  final bool isSelected = selectedCategory == category;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      selectedColor: const Color(0xffE5D9FA),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.deepPurple : Colors.black54,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      onSelected: (_) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            // ================= TASK HEADER =================
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Tasks',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${filteredTasks.length} Tasks',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),

            // ================= TASK LIST =================
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.task_alt,
                            size: 60,
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No tasks found!',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Add a new task to get started',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: loadTasks,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh tasks'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final Task task = filteredTasks[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // CHECKBOX
                              Checkbox(
                                value: task.completed,
                                activeColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                onChanged: (value) {
                                  toggleTask(task, value);
                                },
                              ),

                              // TASK INFORMATION
                              Expanded(
                                child: InkWell(
                                  onTap: () => editTask(task),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          decoration: task.completed
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                          color: task.completed
                                              ? Colors.grey
                                              : Colors.black87,
                                        ),
                                      ),

                                      const SizedBox(height: 5),

                                      Text(
                                        task.category,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.deepPurple,
                                        ),
                                      ),

                                      if (task.dueDate != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.access_time,
                                                size: 12,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  formatDate(task.dueDate!),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),

                              // EDIT BUTTON
                              IconButton(
                                onPressed: () => editTask(task),
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.deepPurple,
                                  size: 21,
                                ),
                              ),

                              // DELETE BUTTON
                              IconButton(
                                onPressed: () => deleteTask(task),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                  size: 21,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // ================= ADD TASK FIELD =================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xffEEEEEE))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: taskController,
                      focusNode: taskFocusNode,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => addTask(),
                      decoration: InputDecoration(
                        hintText: 'Add a new task...',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: const Color(0xffF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 13,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ADD BUTTON
                  Material(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: isAddingTask ? null : addTask,
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: isAddingTask
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.arrow_upward,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
