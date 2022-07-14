import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_tracker_client/core/setup/injectable.dart';
import 'package:time_tracker_client/core/widgets/top_loader.dart';
import 'package:time_tracker_client/data/models/auth/user.dart';
import 'package:time_tracker_client/screens/dashboard/bloc/bloc.dart';
import 'package:time_tracker_client/screens/dashboard/screens/tracking/bloc/bloc.dart';
import 'package:time_tracker_client/screens/dashboard/screens/tracking/widgets/add_project_button.dart';
import 'package:time_tracker_client/screens/dashboard/screens/tracking/widgets/projects_list.dart';

class TrackingScreen extends StatefulWidget implements AutoRouteWrapper {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProjectsBloc>(),
      child: this,
    );
  }
}

class _TrackingScreenState extends State<TrackingScreen> {
  @override
  void initState() {
    context.read<ProjectsBloc>().add(LoadProjectsEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state as UserState;
    final user = authState.user;

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16, top: 4),
      child: BlocBuilder<ProjectsBloc, ProjectsState>(
        builder: (context, state) {
          final failure = state is FetchFailedState ? state.failure : null;
          final isLoading = state is FetchProjectsState;
          final body = state is ProjectsLoadedState
              ? ProjectsList(projects: state.projects)
              : null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TopLoader(isLoading: isLoading, failure: failure),
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: body,
                ),
              ),
              if (user.role == UserRole.admin)
                AddProjectButton(isActive: state is ProjectsLoadedState),
            ],
          );
        },
      ),
    );
  }
}