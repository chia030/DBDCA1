# DBD Compulsory Assignment #1

## Practical Info
The /master branch contains the solutions to the exercises 1, 2 and 3.
The initial stored procedures are defined in ./sql_scripts/CreateStoredProcedures.sql and the application is in ./src/Main.java.
To complete exercise 3, I added another script (./sql_scripts/AddCalculatedColumn.sql) which creates the EmpCount column in Departments and changes the stored procedures accordingly.

![image](https://user-images.githubusercontent.com/58979857/224846826-267809ff-78fc-41cf-8a58-33b9c2638ed8.png)
You will need to change the connection to be able to run the app.

## Reflections on my work
I think there are some things I could have done better!

I could have run the SQL scripts from the application at startup instead of manually running them with the IDE.

I also think that the solution I have for the third exercise could be improved.
![image](https://user-images.githubusercontent.com/58979857/224847507-3a5d610f-cc24-40fe-a8d8-332a2178507a.png)

I decided to create a new stored procedure to fetch the EmpCount value for one department but it is only executed within other stored procedures so it could have been a function instead of a stored procedure.

And worst of all, it is not executed after a trigger occurs, which would have been ideal since the EmpCount is mostly dependent on changes that happen to the Employee table, not the department table.

Other than this, I think the rest of the solutions are okay. 😀

Chiara Visca (chivis01)
