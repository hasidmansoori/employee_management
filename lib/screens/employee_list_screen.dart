import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/employee_cubit.dart';
import 'employee_form_screen.dart';
import '../models/employee_model.dart';

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // 🔵 Blue AppBar
        title: const Text(
          "Employee List",
          style: TextStyle(color: Colors.white), // ⚪ White Title
        ),
        iconTheme: const IconThemeData(color: Colors.white), // ⚪ White Back Button
      ),
      body: BlocBuilder<EmployeeCubit, List<Employee>>(
        builder: (context, employees) {
          if (employees.isEmpty) {
            return _buildEmptyState();
          }
          return _buildEmployeeList(employees, context);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEmployeeForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// ✅ Displays a message & image when no employees are available
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/nolist.png", width: 200),

        ],
      ),
    );
  }

  /// ✅ Displays a list of employees with edit & delete actions
  Widget _buildEmployeeList(List<Employee> employees, BuildContext context) {
    return ListView.builder(
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(employee.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            subtitle: Text(
              "${employee.role} | ${_formatDate(employee.joiningDate)} - ${employee.endDate != null ? _formatDate(employee.endDate!) : 'Present'}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _editEmployee(context, index, employee)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteEmployee(context, index)),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ✅ Formats DateTime to a readable format
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  /// ✅ Navigates to Add Employee Form
  void _navigateToEmployeeForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmployeeFormScreen()),
    );
  }

  /// ✅ Navigates to Edit Employee Form
  void _editEmployee(BuildContext context, int index, Employee employee) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EmployeeFormScreen(employee: employee, index: index)),
    );
  }

  /// ✅ Deletes an Employee using EmployeeCubit
  void _deleteEmployee(BuildContext context, int index) {
    context.read<EmployeeCubit>().deleteEmployee(index);
  }
}
