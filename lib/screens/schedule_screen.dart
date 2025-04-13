import 'package:flutter/material.dart';
import '../models/schedule.dart';
import '../services/api_service.dart';
import 'schedule_form_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> with SingleTickerProviderStateMixin {
  final _apiService = ApiService();
  List<Schedule> _schedules = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _loadSchedules();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final schedules = await _apiService.getSchedules();
      setState(() {
        _schedules = schedules;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du chargement des horaires'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSchedule(Schedule schedule) async {
    try {
      await _apiService.deleteSchedule(schedule.id);
      setState(() {
        _schedules.removeWhere((s) => s.id == schedule.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Horaire supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la suppression de l\'horaire'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Horaires'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSchedules,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _schedules.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 64,
                        color: colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun horaire disponible',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final newSchedule = await Navigator.push<Schedule>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ScheduleFormScreen(),
                            ),
                          );
                          if (newSchedule != null) {
                            setState(() {
                              _schedules.add(newSchedule);
                            });
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter un horaire'),
                      ),
                    ],
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: ListView.builder(
                    itemCount: _schedules.length,
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      final schedule = _schedules[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colorScheme.primary.withOpacity(0.1),
                            child: Icon(
                              Icons.access_time,
                              color: colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            schedule.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${schedule.startTime.toString().substring(0, 16)} - ${schedule.endTime.toString().substring(0, 16)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  final updatedSchedule =
                                      await Navigator.push<Schedule>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ScheduleFormScreen(
                                        schedule: schedule,
                                      ),
                                    ),
                                  );
                                  if (updatedSchedule != null) {
                                    setState(() {
                                      _schedules[index] = updatedSchedule;
                                    });
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirmation'),
                                      content: const Text(
                                        'Êtes-vous sûr de vouloir supprimer cet horaire ?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Annuler'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deleteSchedule(schedule);
                                          },
                                          child: Text(
                                            'Supprimer',
                                            style: TextStyle(color: colorScheme.error),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: _schedules.isNotEmpty
          ? FloatingActionButton(
              onPressed: () async {
                final newSchedule = await Navigator.push<Schedule>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScheduleFormScreen(),
                  ),
                );
                if (newSchedule != null) {
                  setState(() {
                    _schedules.add(newSchedule);
                  });
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
} 