import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import '../models/employee_model.dart';

class EmployeeCubit extends Cubit<List<Employee>> {
  final Box employeeBox = Hive.box('employees');

  EmployeeCubit() : super([]);

  void loadEmployees() {
    final employees = employeeBox.values.cast<Employee>().toList();
    emit(employees);
  }

  void addEmployee(Employee employee) {
    employeeBox.add(employee);
    loadEmployees();
  }

  void updateEmployee(int index, Employee employee) {
    employeeBox.putAt(index, employee);
    loadEmployees();
  }

  void deleteEmployee(int index) {
    employeeBox.deleteAt(index);
    loadEmployees();
  }
}
