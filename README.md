# Bank-transactions-processing-system
Project Overview
This project implements a robust banking transaction management system using PL/SQL. It processes transactions like deposits, withdrawals, and account updates while ensuring data consistency and integrity. The system is designed to handle pending transactions efficiently and maintains error handling for critical operations such as insufficient funds and nonexistent accounts.

Key Features
Automated Transactions:
Processes deposits and withdrawals dynamically.
Updates account balances in real-time.
Pending Transactions Handling:
Automatically resolves transactions marked as pending.
Error Handling:
Ensures minimum balance compliance.
Validates account existence and handles exceptions gracefully.
Database Schema
1. account_info_tab
Stores account details:

Columns:
accountno, account_holder_name, account_type, branch_name, currentbalance, opened_date, status
2. transactions_tab
Logs all transactions:

Columns:
transaction_no, accountno, deposit_or_withdrawal, amount, tran_status, transaction_datetime, transaction_mode, remarks
Code Implementation
The project uses a PL/SQL package bank_transactions_gen with the following structure:

Package Specification
Constants:
cns_minimum_balance: Ensures accounts maintain a minimum balance of 1000.
Procedures:
apply_transactions: Processes all pending transactions.
transaction_entry: Adds new transaction records.
Package Body
Key Procedures:
credit_account:
Credits the specified amount to the account.
debit_account:
Debits the specified amount if sufficient funds are available.
apply_transactions:
Processes pending transactions sequentially.
transaction_entry:
Inserts a new transaction entry into the transactions_tab.
Code Usage
Insert Transaction:
sql
Copy
Edit
BEGIN
    bank_transactions_gen.transaction_entry(
        p_accountno => 9247168626,
        p_transaction_type => 'D',
        p_amount => 500
    );
END;
Apply Transactions:
sql
Copy
Edit
BEGIN
    bank_transactions_gen.apply_transactions;
END;
Execution Steps
Create tables account_info_tab and transactions_tab.
Execute the provided PL/SQL package and procedures.
Insert sample data into the tables.
Run the transaction_entry procedure to log transactions.
Execute the apply_transactions procedure to process pending transactions.
Sample Output
1. Before Execution
account_info_tab:

accountno	currentbalance
9247168626	1500
transactions_tab:

transaction_no	accountno	deposit_or_withdrawal	amount	tran_status
1	9247168626	D	500	pending
2. After Execution
account_info_tab:

accountno	currentbalance
9247168626	1000
transactions_tab:

transaction_no	accountno	deposit_or_withdrawal	amount	tran_status
1	9247168626	D	500	Debit
Technologies Used
Database: Oracle SQL
Language: PL/SQL
Tools: SQL Developer, Notepad++
Challenges and Learnings
Challenges:
Ensuring data consistency in concurrent transactions.
Managing exceptions like insufficient funds and nonexistent accounts.
Learnings:
Developing reusable PL/SQL procedures.
Effective transaction management in databases.
