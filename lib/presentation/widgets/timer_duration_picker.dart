import 'package:flutter/material.dart';

class TimerDurationPicker extends StatefulWidget {
  final Function(int minutes) onDurationSelected;

  const TimerDurationPicker({super.key, required this.onDurationSelected});

  @override
  State<TimerDurationPicker> createState() => _TimerDurationPickerState();
}

class _TimerDurationPickerState extends State<TimerDurationPicker> {
  int _selectedMinutes = 20; // Default to 20 minutes

  final List<int> _presetMinutes = [5, 10, 15, 20, 25, 30, 45, 60, 90, 120];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Reading Timer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'How long would you like to read?',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          // Preset buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presetMinutes.map((minutes) {
              final isSelected = _selectedMinutes == minutes;
              return ChoiceChip(
                label: Text('${minutes}m'),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedMinutes = minutes;
                    });
                  }
                },
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurface,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Custom duration
          Text(
            'Custom duration:',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: _selectedMinutes > 1
                    ? () {
                        setState(() {
                          _selectedMinutes--;
                        });
                      }
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Expanded(
                child: Text(
                  '$_selectedMinutes minutes',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                onPressed: _selectedMinutes < 300
                    ? () {
                        setState(() {
                          _selectedMinutes++;
                        });
                      }
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onDurationSelected(_selectedMinutes);
            Navigator.of(context).pop();
          },
          child: const Text('Set Timer'),
        ),
      ],
    );
  }
}
