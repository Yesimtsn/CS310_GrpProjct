import 'package:flutter/material.dart';

import '../data/campus_locations.dart';
import '../models/event.dart';
import '../utils/date_format.dart';
import '../utils/validators.dart';
import 'app_text_field.dart';

/// Values the form collects. The screen passes them to EventService.
class EventFormData {
  final String title;
  final EventCategory category;
  final DateTime dateTime;
  final String location;
  final int maxParticipants;
  final String description;

  const EventFormData({
    required this.title,
    required this.category,
    required this.dateTime,
    required this.location,
    required this.maxParticipants,
    required this.description,
  });
}

/// Create / Edit event form (2.1 "Create Event" wireframe).
/// Calls [onSubmit] only when every field is valid.
/// Pass [initialEvent] to pre-fill it (Edit Event can reuse this widget).
class EventForm extends StatefulWidget {
  final Event? initialEvent;
  final String submitLabel;
  final ValueChanged<EventFormData> onSubmit;

  const EventForm({
    super.key,
    this.initialEvent,
    required this.submitLabel,
    required this.onSubmit,
  });

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _timeCtrl;
  late final TextEditingController _maxCtrl;
  late final TextEditingController _descriptionCtrl;

  EventCategory? _category;
  String? _location;
  DateTime? _date; // date part only
  TimeOfDay? _time;

  @override
  void initState() {
    super.initState();
    final e = widget.initialEvent;
    _category = e?.category;
    // Only pre-select a location that is still in the dropdown.
    _location = (e != null && campusLocations.contains(e.location))
        ? e.location
        : null;
    _date = e == null
        ? null
        : DateTime(e.dateTime.year, e.dateTime.month, e.dateTime.day);
    _time = e == null ? null : TimeOfDay.fromDateTime(e.dateTime);

    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _dateCtrl = TextEditingController(
      text: e == null ? '' : DateFormatter.date(e.dateTime),
    );
    _timeCtrl = TextEditingController(
      text: e == null ? '' : DateFormatter.time(e.dateTime),
    );
    _maxCtrl = TextEditingController(text: e?.maxParticipants.toString() ?? '');
    _descriptionCtrl = TextEditingController(text: e?.description ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _maxCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  /// Date + time combined, or null if a picker is still empty.
  DateTime? get _dateTime => (_date == null || _time == null)
      ? null
      : DateFormatter.combine(_date!, _time!.hour, _time!.minute);

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // initialDate must not be before firstDate or the picker throws.
    final initial = (_date != null && !_date!.isBefore(today)) ? _date! : today;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      _dateCtrl.text = DateFormatter.date(picked);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked == null) return;
    setState(() {
      _time = picked;
      _timeCtrl.text = DateFormatter.time(
        DateFormatter.combine(DateTime.now(), picked.hour, picked.minute),
      );
    });
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    widget.onSubmit(
      EventFormData(
        title: _titleCtrl.text.trim(),
        category: _category!,
        dateTime: _dateTime!,
        location: _location!,
        maxParticipants: int.parse(_maxCtrl.text.trim()),
        description: _descriptionCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 16);

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _titleCtrl,
              label: 'Title',
              icon: Icons.title,
              textInputAction: TextInputAction.next,
              validator: Validators.eventTitle,
            ),
            gap,
            DropdownButtonFormField<EventCategory>(
              initialValue: _category,
              isExpanded: true,
              decoration: const InputDecoration(
                hintText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: [
                for (final c in EventCategory.values)
                  DropdownMenuItem(value: c, child: Text(c.label)),
              ],
              onChanged: (v) => setState(() => _category = v),
              validator: (v) => Validators.requiredChoice(v, 'Category'),
            ),
            gap,
            _PickerField(
              controller: _dateCtrl,
              hint: 'Date',
              icon: Icons.calendar_today_outlined,
              onTap: _pickDate,
              validator: (_) => _date == null ? 'Date is required' : null,
            ),
            gap,
            _PickerField(
              controller: _timeCtrl,
              hint: 'Time',
              icon: Icons.access_time,
              onTap: _pickTime,
              // Same rule the service checks: date + time must be in the future.
              validator: (_) => _time == null
                  ? 'Time is required'
                  : Validators.eventDateTime(_dateTime),
            ),
            gap,
            DropdownButtonFormField<String>(
              initialValue: _location,
              isExpanded: true,
              decoration: const InputDecoration(
                hintText: 'Location',
                prefixIcon: Icon(Icons.place_outlined),
              ),
              items: [
                for (final place in campusLocations)
                  DropdownMenuItem(
                    value: place,
                    child: Text(place, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) => setState(() => _location = v),
              validator: (v) => Validators.requiredChoice(v, 'Location'),
            ),
            gap,
            AppTextField(
              controller: _maxCtrl,
              label: 'Max participants',
              icon: Icons.group_outlined,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              // On Edit, capacity can't go below people already joined.
              validator: (v) => Validators.maxParticipantsField(
                v,
                currentAttendees: widget.initialEvent?.attendeeCount ?? 0,
              ),
            ),
            gap,
            TextFormField(
              controller: _descriptionCtrl,
              maxLines: 4,
              minLines: 3,
              maxLength: Validators.maxDescriptionLength,
              keyboardType: TextInputType.multiline,
              validator: Validators.description,
              decoration: const InputDecoration(
                hintText: 'Description',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: Text(widget.submitLabel),
            ),
          ],
        ),
      ),
    );
  }
}

/// Read-only field that opens a date or time picker when tapped.
class _PickerField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final VoidCallback onTap;
  final FormFieldValidator<String> validator;

  const _PickerField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.onTap,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(hintText: hint, suffixIcon: Icon(icon)),
    );
  }
}
