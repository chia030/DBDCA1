import java.sql.*;
        import java.util.Scanner;

public class Main {

    private static Connection conn;
    private static Scanner scanner;

    public static void main(String[] args) {
        scanner = new Scanner(System.in);
        String dbURL = "jdbc:sqlserver://CHIASEED-LAPTOP;databaseName=Company;encrypt=true;trustServerCertificate=true;";
        try {
            conn = DriverManager.getConnection(dbURL, "test", "test");
            System.out.println("Connected to DB.");

            boolean exit = false;
            while (!exit) {
                System.out.println("Select an option:");
                System.out.println("1. Add a department");
                System.out.println("2. Update a department name");
                System.out.println("3. Update a department manager");
                System.out.println("4. Delete a department");
                System.out.println("5. Get department by number");
                System.out.println("6. Get all departments");
                System.out.println("7. Exit");

                int option = scanner.nextInt();
                scanner.nextLine();

                switch (option) {
                    case 1:
                        createDepartment();
                        break;
                    case 2:
                        updateDepartmentName();
                        break;
                    case 3:
                        updateDepartmentManager();
                        break;
                    case 4:
                        deleteDepartment();
                        break;
                    case 5:
                        getDepartmentByNumber();
                        break;
                    case 6:
                        getAllDepartments();
                        break;
                    case 7:
                        exit = true;
                        break;
                    default:
                        System.out.println("Select a valid option, please.");
                }
            }

            conn.close();
            System.out.println("Disconnected from DB.");
        } catch (SQLException ex) {
            System.out.println("Error: " + ex.getMessage());
        }
    }

    public static void createDepartment() {
        try {
            System.out.print("Enter department name: ");
            String dName = scanner.nextLine();
            System.out.print("Enter manager SSN: ");
            int mgrSSN = scanner.nextInt();

            CallableStatement stmt = conn.prepareCall("{CALL usp_CreateDepartment(?, ?)}");
            stmt.setString(1, dName);
            stmt.setInt(2, mgrSSN);

            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                System.out.println("Department added! :) The department number is " + rs.getInt("DNumber"));
            }

        } catch (SQLException ex) {
            System.out.println("Error: " + ex.getMessage());
        }
    }

    public static void updateDepartmentName() {
        try {
            System.out.print("Enter department number: ");
            int dNumber = scanner.nextInt();
            scanner.nextLine();
            System.out.print("Enter new department name: ");
            String dName = scanner.nextLine();

            CallableStatement stmt = conn.prepareCall("{CALL usp_UpdateDepartmentName(?, ?)}");
            stmt.setInt(1, dNumber);
            stmt.setString(2, dName);

            stmt.execute();

            System.out.println("Department name updated! :)");
        } catch (SQLException ex) {
            System.out.println("An error occurred: " + ex.getMessage());
        }
    }

    public static void updateDepartmentManager() {
        try {
            System.out.print("Enter department number: ");
            int dNumber = scanner.nextInt();
            scanner.nextLine();
            System.out.print("Enter new manager SSN: ");
            int mgrSSN = scanner.nextInt();
            CallableStatement stmt = conn.prepareCall("{call usp_UpdateDepartmentManager(?, ?)}");
            stmt.setInt(1, dNumber);
            stmt.setInt(2, mgrSSN);

            stmt.execute();

            System.out.println("Department manager updated! :)");
        } catch (SQLException e) {
            System.out.println("Error: " + e.getMessage());
        }
    }

    public static void deleteDepartment() {
        try {
            System.out.println("Enter department number:");
            int dNumber = scanner.nextInt();

            CallableStatement stmt = conn.prepareCall("{call usp_DeleteDepartment(?)}");
            stmt.setInt(1, dNumber);

            stmt.execute();

            System.out.println("Department deleted successfully.");
        } catch (SQLException e) {
            System.out.println("Error: " + e.getMessage());
        }
    }

    public static void getDepartmentByNumber() {
        try {
            System.out.println("Enter department number:");
            int dNumber = scanner.nextInt();

            CallableStatement stmt = conn.prepareCall("{call usp_GetDepartment(?)}");
            stmt.setInt(1, dNumber);

            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                System.out.println("Department Number: " + rs.getInt("DNumber"));
                System.out.println("Department Name: " + rs.getString("DName"));
                System.out.println("Manager SSN: " + rs.getInt("MgrSSN"));
                System.out.println("Manager Start Date: " + rs.getDate("MgrStartDate"));
                System.out.println("Employee Count: " + rs.getInt("EmpCount"));
            } else {
                System.out.println("Department not found. :(");
            }

            rs.close();
        } catch (SQLException e) {
            System.out.println("Error: " + e.getMessage());
        }
    }

    public static void getAllDepartments() {
        try {
            CallableStatement stmt = conn.prepareCall("{call usp_GetAllDepartments()}");

            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                System.out.println("Department Number: " + rs.getInt("DNumber"));
                System.out.println("Department Name: " + rs.getString("DName"));
                System.out.println("Manager SSN: " + rs.getInt("MgrSSN"));
                System.out.println("Manager Start Date: " + rs.getDate("MgrStartDate"));
                System.out.println("Employee Count: " + rs.getInt("EmpCount"));
                System.out.println("-----------------------");
            }

            rs.close();
        } catch (SQLException e) {
            System.out.println("Error: " + e.getMessage());
        }
    }
}
