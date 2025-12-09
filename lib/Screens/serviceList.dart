import 'package:flutter/material.dart';
import 'package:health_fit_strong/Widgets/Catergory.dart';
import 'package:health_fit_strong/Widgets/ServiceCard.dart';
import 'package:health_fit_strong/provider/serviceProvider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';


class ServicesListScreen extends StatefulWidget {
  const ServicesListScreen({super.key});

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final serviceProvider = context.watch<ServiceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Services'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search services...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => serviceProvider.searchServices(value),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: serviceProvider.categories.length,
              itemBuilder: (context, index) {
                final category = serviceProvider.categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CategoryChip(
                    label: category,
                    isSelected: serviceProvider.selectedCategory == category ||
                        (category == 'All' && serviceProvider.selectedCategory == null),
                    onTap: () => serviceProvider.filterByCategory(category),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: serviceProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: serviceProvider.services.length,
                    itemBuilder: (context, index) {
                      final service = serviceProvider.services[index];
                      return ServiceCard(
                        service: service,
                        onTap: () => context.push('/service/${service.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}