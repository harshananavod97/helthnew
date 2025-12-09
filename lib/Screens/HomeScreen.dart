import 'package:flutter/material.dart';
import 'package:health_fit_strong/Widgets/ServiceCard.dart';
import 'package:health_fit_strong/provider/serviceProvider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().fetchServices(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBody() {
    final serviceProvider = context.watch<ServiceProvider>();
    
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: const Text('Health Fit Strong'),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text('Popular Services', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ...serviceProvider.services.map((service) {
                return ServiceCard(
                  service: service,
                  onTap: () => context.push('/service/${service.id}'),
                );
              }).toList(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() => _selectedIndex = index);
        switch (index) {
          case 1:
            context.push('/services');
            break;
          case 2:
            context.push('/calendar');
            break;
          case 3:
            context.push('/profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Services'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}