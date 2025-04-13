import 'package:flutter/material.dart';
import '../models/schedule.dart';
import '../services/api_service.dart';

class ScheduleFormScreen extends StatefulWidget {
  final Schedule? schedule;

  const ScheduleFormScreen({Key? key, this.schedule}) : super(key: key);

  @override
  _ScheduleFormScreenState createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends State<ScheduleFormScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _startTime;
  late DateTime _endTime;
  String? _location;
  String? _category;
  List<String> _tags = [];
  String? _color;
  String? _reminder;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.schedule?.title);
    _descriptionController =
        TextEditingController(text: widget.schedule?.description);
    _startTime = widget.schedule?.startTime ?? DateTime.now();
    _endTime = widget.schedule?.endTime ?? DateTime.now().add(const Duration(hours: 1));
    _location = widget.schedule?.location;
    _category = widget.schedule?.category;
    _tags = widget.schedule?.tags ?? [];
    _color = widget.schedule?.color;
    _reminder = widget.schedule?.reminder;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(bool isStartTime) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: isStartTime ? _startTime : _endTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          isStartTime ? _startTime : _endTime,
        ),
      );

      if (time != null) {
        setState(() {
          final DateTime newDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );

          if (isStartTime) {
            _startTime = newDateTime;
          } else {
            _endTime = newDateTime;
          }
        });
      }
    }
  }

  Future<void> _saveSchedule() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final schedule = Schedule(
          id: widget.schedule?.id ?? 0,
          title: _titleController.text,
          description: _descriptionController.text,
          startTime: _startTime,
          endTime: _endTime,
          location: _location,
          category: _category,
          tags: _tags,
          color: _color,
          reminder: _reminder,
          userId: widget.schedule?.userId ?? 0,
          isCompleted: widget.schedule?.isCompleted ?? false,
          createdAt: widget.schedule?.createdAt,
          updatedAt: DateTime.now(),
        );

        final savedSchedule = widget.schedule == null
            ? await _apiService.createSchedule(schedule)
            : await _apiService.updateSchedule(schedule);

        if (mounted) {
          Navigator.pop(context, savedSchedule);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la sauvegarde de l\'horaire'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.schedule == null ? 'Nouvel Horaire' : 'Modifier l\'Horaire'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Titre',
                            prefixIcon: Icon(Icons.title, color: colorScheme.primary),
                            hintText: 'Entrez un titre pour votre horaire',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un titre';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            prefixIcon: Icon(Icons.description, color: colorScheme.primary),
                            hintText: 'Décrivez votre horaire',
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer une description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _selectDateTime(true),
                                icon: Icon(Icons.access_time, color: colorScheme.primary),
                                label: Text(
                                  'Début: ${_startTime.toString().substring(0, 16)}',
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _selectDateTime(false),
                                icon: Icon(Icons.access_time, color: colorScheme.primary),
                                label: Text(
                                  'Fin: ${_endTime.toString().substring(0, 16)}',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _location,
                          decoration: InputDecoration(
                            labelText: 'Lieu',
                            prefixIcon: Icon(Icons.location_on, color: colorScheme.primary),
                            hintText: 'Entrez le lieu de l\'horaire',
                          ),
                          onChanged: (value) => _location = value,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _category,
                          decoration: InputDecoration(
                            labelText: 'Catégorie',
                            prefixIcon: Icon(Icons.category, color: colorScheme.primary),
                            hintText: 'Entrez une catégorie',
                          ),
                          onChanged: (value) => _category = value,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _saveSchedule,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Enregistrer',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
} 