create or replace package bank_transactions_gen
as
cns_minimum_balance constant number := 1000.00;
    procedure apply_transactions;
    procedure transaction_entry(
        p_accountno in number,
        p_transaction_type in varchar2,
        p_amount in number
        );
end bank_transactions_gen;
/
create or replace package body bank_transactions_gen
as
    /* package to input bank transaction */
    new_status varchar2(4000);

    /* global variable to record status of transaction being applied.
    used for update in apply_transactions. */

    procedure do_transaction_entry(
        p_accountno number,
        p_transaction_type varchar2)
    is
    begin
        if p_transaction_type = 'D' then
            new_status := 'Debit';
        ELSIF p_transaction_type = 'C' THEN
            new_status := 'Credit';
        ELSE
            new_status := 'New Account';
        END IF;

        --INSERT INTO transactions_tab(transaction_no, accountno, deposit_or_withdrawal, transaction_datetime)
        --VALUES (tran_seqno.nextval, p_accountno, p_transaction_type, sysdate);
    END do_transaction_entry;

    procedure credit_account(p_accountno number, p_credit number) 
    is
        old_balance number;
        new_balance number;
    begin
        select currentbalance INTO old_balance from account_info_tab
        where accountno = p_accountno
        for update of currentbalance;

        new_balance := old_balance + p_credit;

        update account_info_tab set currentbalance = new_balance
        where accountno = p_accountno;

        do_transaction_entry(p_accountno, 'C');

    exception 
        when no_data_found then
            insert into account_info_tab(accountno, currentbalance)
            values(p_accountno, p_credit);
            do_transaction_entry(p_accountno, 'N');

        when others then
            new_status := SUBSTR('Error: ' || sqlerrm(sqlcode), 1, 20);
    END credit_account;

    procedure debit_account(p_accountno number, p_debit number)
    is
        old_balance number;
        new_balance number;
        insufficient_funds exception;
    begin
        select currentbalance into old_balance from account_info_tab
        where accountno = p_accountno
        for update of currentbalance;

        new_balance := old_balance - p_debit;

        if new_balance >= cns_minimum_balance then
            update account_info_tab set currentbalance = new_balance
            WHERE accountno = p_accountno;
            do_transaction_entry(p_accountno, 'D');
        ELSE
            raise insufficient_funds;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            new_status := 'Nonexistent Account';
        WHEN insufficient_funds THEN
            new_status := 'Insufficient Funds';
    END debit_account;

    procedure apply_transactions is
        cursor trans_cursor is
            select accountno, deposit_or_withdrawal, amount from transactions_tab
            where tran_status = 'pending'
            order by transaction_datetime
            for update of tran_status;
    begin
        for trans in trans_cursor loop
            if trans.deposit_or_withdrawal = 'D' then
                debit_account(trans.accountno, trans.amount);
            elsif trans.deposit_or_withdrawal = 'C' then
                credit_account(trans.accountno, trans.amount);
            else
                new_status := 'Rejected';
            end if;

            update transactions_tab
            set tran_status = new_status
            where current of trans_cursor;
        end loop;
        commit;
    end apply_transactions;

    -- Define the transaction_entry procedure
    procedure transaction_entry(
        p_accountno number,
        p_transaction_type varchar2,
        p_amount number)
    is
    begin
        INSERT INTO transactions_tab(transaction_no, accountno, deposit_or_withdrawal, amount, tran_status, transaction_datetime)
        values (tran_seqno.nextval, p_accountno, p_transaction_type, p_amount, 'pending', sysdate);
        COMMIT;
    END transaction_entry;

END bank_transactions_gen;
/
CREATE SEQUENCE tran_seqno
    START WITH 301
    INCREMENT BY 1
    NOCACHE;
/
set serveroutput on;
exec bank_transactions_gen.apply_transactions;
/
BEGIN
  -- Test applying transactions (this should process any pending transactions)
  bank_transactions_gen.apply_transactions;
END;
/
BEGIN
  bank_transactions_gen.transaction_entry(p_accountno => 9247168626,p_transaction_type => 'D',p_amount => 500);
END;
/
exec bank_transactions_gen.transaction_entry(p_accountno => 9247168627, p_transaction_type => 'D', p_amount => 10400);
exec bank_transactions_gen.transaction_entry(p_accountno => 9247168628, p_transaction_type => 'C', p_amount => 345456);
exec bank_transactions_gen.transaction_entry(p_accountno => 9247168629, p_transaction_type => 'C', p_amount => 11551);
exec bank_transactions_gen.transaction_entry(p_accountno => 9247168630, p_transaction_type => 'D', p_amount => 14554);
exec bank_transactions_gen.transaction_entry(p_accountno => 9247168631, p_transaction_type => 'D', p_amount => 14514);
exec bank_transactions_gen.transaction_entry(p_accountno => 9247168632, p_transaction_type => 'D', p_amount => 11415);
exec bank_transactions_gen.transaction_entry(p_accountno => 9247168633, p_transaction_type => 'C', p_amount => 11515);
exec bank_transactions_gen.transaction_entry(p_accountno => 9247168635, p_transaction_type => 'D', p_amount => 142462);
exec bank_transactions_gen.transaction_entry(p_accountno => 9247168637, p_transaction_type => 'C', p_amount => 126464);
exec bank_transactions_gen.transaction_entry(p_accountno => 9247168638, p_transaction_type => 'D', p_amount => 126464);
exec bank_transactions_gen.transaction_entry(p_accountno => 9247168640, p_transaction_type => 'C', p_amount => 164264);
exec bank_transactions_gen.transaction_entry(p_accountno => 9247168641, p_transaction_type => 'C', p_amount => 12646);
exec bank_transactions_gen.transaction_entry(p_accountno => 9247168642, p_transaction_type => 'D', p_amount => 12662);
exec bank_transactions_gen.transaction_entry(p_accountno => 9247168645, p_transaction_type => 'C', p_amount => 126342);
exec bank_transactions_gen.transaction_entry(p_accountno => 9247168626, p_transaction_type => 'D', p_amount => 12662);
exec bank_transactions_gen.transaction_entry(p_accountno => 9247168629, p_transaction_type => 'C', p_amount => 10346);

exec bank_transactions_gen.apply_transactions;
/






