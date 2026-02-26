import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/responsive.dart';
import '../../../../global_components/widgets/app_button.dart';
import '../../../../global_components/widgets/app_text_field.dart';
import '../../data/models/todo_model.dart';
import '../../domain/providers/todo_provider.dart';

class TodoEditScreen extends StatefulWidget {
  const TodoEditScreen({super.key, this.todo});

  final TodoModel? todo;

  @override
  State<TodoEditScreen> createState() => _TodoEditScreenState();
}

class _TodoEditScreenState extends State<TodoEditScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  bool _saving = false;
  late final AnimationController _entranceController;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  late final Animation<double> _fieldOpacity;
  late final Animation<double> _buttonOpacity;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.todo?.title ?? '');
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 380),
      vsync: this,
    );
    _opacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0, 0.5, curve: Curves.easeOutCubic),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0, 0.5, curve: Curves.easeOutCubic),
    ));
    _fieldOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.25, 0.7, curve: Curves.easeOut),
    );
    _buttonOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.45, 0.9, curve: Curves.easeOut),
    );
    Future.microtask(() => _entranceController.forward());
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.todo != null;
    final padding = Responsive.horizontalPadding(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit task' : 'New task'),
      ),
      body: FadeTransition(
        opacity: _opacity,
        child: SlideTransition(
          position: _slide,
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeTransition(
                    opacity: _fieldOpacity,
                    child: AppTextField(
                      controller: _controller,
                      label: 'Title',
                      hint: 'What needs to be done?',
                      autofocus: true,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter a title';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _buttonOpacity,
                    child: Consumer<TodoProvider>(
                      builder: (context, provider, child) {
                        return AppButton(
                          label: isEdit ? 'Save' : 'Add',
                          loading: _saving,
                          onPressed: () => _submit(provider),
                        );
                      },
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

  Future<void> _submit(TodoProvider provider) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final title = _controller.text.trim();
    if (widget.todo != null) {
      await provider.updateTodo(widget.todo!, title);
    } else {
      await provider.addTodo(title);
    }
    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pop();
    }
  }
}
