#!/usr/bin/env python3

import mysql.connector as sql
import pandas as pd
import numpy as np
#ex1
c = sql.connect(host='localhost',database='invoices',user='root',password='shW980125')
def gl_book_accounts(c):
	cmd = ("SELECT * FROM invoices.general_ledger_accounts WHERE account_description LIKE '%Book%'")
	return pd.read_sql(cmd,c,index_col='account_number')
#a = gl_book_accounts(c)
#print(a)

#ex2
#SELECT invoice_number,account_description,line_item_amt
#FROM invoices AS I
#JOIN invoice_line_items AS L USING(invoice_id)
#JOIN general_ledger_accounts AS A USING(account_number)
#LEFT JOIN (SELECT account_number,avg(line_item_amt) as checka FROM invoices.invoice_line_items group by account_number) as i USING(account_number)
#where line_item_amt > checka;

def sql_anomalies(c):
	cmd = (' SELECT invoice_number,account_description,line_item_amt ' +
	' FROM invoices AS I ' +
	' JOIN invoice_line_items AS L USING(invoice_id) ' +
	' JOIN general_ledger_accounts AS A USING(account_number) ' +
	' LEFT JOIN (SELECT account_number,avg(line_item_amt) as checka FROM invoices.invoice_line_items group by account_number) as i USING(account_number) ' +
	' where line_item_amt > checka; '
	)
	return pd.read_sql(cmd,c)
#a = sql_anomalies(c)
#print(a)
def pd_anomalies(c):
	invoice_df = pd.read_sql('SELECT * FROM invoices',c,index_col='invoice_id')
	line_item_df = pd.read_sql('SELECT * FROM invoice_line_items',c)
	invoice_df = pd.merge(invoice_df,line_item_df,on='invoice_id')
	get_avg = line_item_df.groupby('account_number').mean()['line_item_amt']
	account_df = pd.read_sql('SELECT * FROM general_ledger_accounts',c)
	account_df = pd.merge(get_avg,account_df,on='account_number')
	account_df.columns = [ 'account_number', 'average','account_description']
	final = pd.merge(account_df,invoice_df,on='account_number')
	return final[final['line_item_amt'] > final['average']][['invoice_number','account_description','line_item_amt']].reset_index()
#print(pd_anomalies(c))

#ex3
c = sql.connect(host='localhost',database='a6',user='root',password='shW980125')
def states_w_n_justices(c, filename, numbers):
	state_number = pd.read_sql('SELECT state,count(state) FROM justice group by state',c)
	state_name = pd.read_csv(filename,header=None)
	state_name = state_name[[0,1]]
	state_name.columns = ['full_name', 'state']
	
	if numbers != 0:
		get_state = state_number[state_number['count(state)'] == numbers]['state']
		return np.array(state_name[state_name.state.isin(get_state)]['full_name'])
	else:
		get_state = state_number['state']
		return np.unique(np.array(state_name[~state_name.state.isin(get_state)]['full_name']))
	
	#print(states_w_n_justices(c, 'usstates.csv', 0))

#ex4
#SET sql_mode = 'NO_UNSIGNED_SUBTRACTION';
#WITH total AS(
#SELECT *,
#	RANK() OVER (PARTITION BY Year ORDER BY profit DESC) AS pro_rank
#FROM a6.fortune500)
#SELECT Company FROM total
#LEFT JOIN (SELECT `Year`, max(pro_rank - `Rank`) as yearmax FROM total GROUP BY `Year`) as m USING(`Year`)
#WHERE `Year` = 2005 and pro_rank - `Rank` = yearmax
#;
def rank_diff_sql(c, y):
	cmd = (
		" WITH total AS( " +
		" SELECT *, " +
		" RANK() OVER (PARTITION BY Year ORDER BY profit DESC) AS pro_rank " +
		" FROM a6.fortune500) " +
		" SELECT Company FROM total " +
		" LEFT JOIN (SELECT `Year`, max(CAST(pro_rank AS decimal) - CAST(`Rank` AS decimal)) as yearmax FROM total GROUP BY `Year`) as m USING(`Year`) " +
		" WHERE `Year` = " + str(y) + " and CAST(pro_rank AS decimal) - CAST(`Rank` AS decimal) = yearmax;"
	)
	df = pd.read_sql(cmd,c)
	return np.array(df['Company'])
#print(rank_diff_sql(c, 2005))