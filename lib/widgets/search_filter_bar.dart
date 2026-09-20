import 'package:flutter/material.dart';
import '../providers/job_provider.dart';

class SearchFilterBar extends StatelessWidget {
  final TextEditingController controller;
  final List<String> jobTypes;
  final String? selectedType;
  final JobSort sort;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<JobSort> onSortChanged;

  const SearchFilterBar({
    super.key,
    required this.controller,
    required this.jobTypes,
    required this.selectedType,
    required this.sort,
    required this.onSearchChanged,
    required this.onTypeChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search title, company or location',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            controller.clear();
                            onSearchChanged('');
                          },
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<JobSort>(
              icon: const Icon(Icons.sort_rounded),
              tooltip: 'Sort',
              initialValue: sort,
              onSelected: onSortChanged,
              itemBuilder: (context) => const [
                PopupMenuItem(
                    value: JobSort.newest, child: Text('Newest first')),
                PopupMenuItem(
                    value: JobSort.companyAZ, child: Text('Company A-Z')),
                PopupMenuItem(
                    value: JobSort.titleAZ, child: Text('Title A-Z')),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _chip(context, 'All', selectedType == null, () => onTypeChanged(null)),
              const SizedBox(width: 8),
              ...jobTypes.map(
                (type) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _chip(
                      context, type, selectedType == type, () => onTypeChanged(type)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(BuildContext context, String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
