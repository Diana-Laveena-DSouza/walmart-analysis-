proc import file='/home/u61251187/sasuser.v94/Walmart_Store_sales.csv'
out=walmart dbms=csv replace;
run;
proc print data=walmart;
run;

/* structure of the data */
proc contents data=walmart varnum;
run;

/*Task 1: Finding the store which has maximum sales */
/* Aggregating Weekly_Sales across the stores using sum function.*/
proc sql;
create table sum_sales as 
select Store, sum(Weekly_Sales) as sum_weekly_sales from walmart group by Store;
run;
proc print data=sum_sales;
run;
/*Filtering the record of that store which has maximum sales*/
proc sql;
select * from sum_sales having sum_weekly_sales=max(sum_weekly_sales) ;
run;

/*Task 2: Finding mean and standard deviation of Weekly_Sales for each Store*/
proc sql;
create table avg_std as
select Store , avg(Weekly_Sales) as average,  std(Weekly_Sales) as std from walmart group by Store;
run;
/* Finding Coefficient of variation */
proc sql;
select *, std/average from avg_std;
run;
/*Filtering the record of that store which has maximum standard deviation*/
proc sql;
select * from avg_std having std=max(std);
run;

/*Task 3: top five which has good growth Q3'2012 rate */
/*Extracting the Quarter and Year from Date */
data growth;
set walmart;
quarter_years=cat(QTR(Date),"-", year(Date));
run;
/*Filtering the records having Q2'2012 and Q3'2012 Quart_Year values*/
proc sql;
create table Q3 as
select Store, sum(Weekly_Sales) as Q3_Sum, quarter_years from growth where quarter_years='3-2012' group by Store, quarter_years;
create table Q2 as
select Store, sum(Weekly_Sales) as Q2_Sum, quarter_years from growth where quarter_years='2-2012' group by Store, quarter_years;
run;
/*Finding growth rate for Q3'2012 for each Store*/
proc sql;
create table Q3_Growth as
select Q3.Store, (Q3.Q3_Sum-Q2.Q2_Sum)/Q2.Q2_Sum as Qgrowth from Q3 inner join Q2 on Q3.Store=Q2.Store;
run;

proc sql outobs=5;
select * from Q3_growth order by Qgrowth desc;
run;

/*Task4: holiday records whose sales are more than mean sale of non-holidays. */
proc sql;
create table nonhol as
select Holiday_Flag, avg(Weekly_Sales) as avg_non from walmart  where Holiday_Flag=0 group by Holiday_Flag;
create table hol as
select walmart.Date, avg(walmart.Weekly_Sales) as avg_hol from walmart where walmart.Holiday_Flag=1 group by walmart.Date;
select hol.Date, hol.avg_hol from hol inner join nonhol on nonhol.avg_non<hol.avg_hol;
run;

/*Task 5: Plotting Month wise sales report */
data months;
set walmart;
month=cat('01-', month(Date), "-", year(Date));
month_year=input(month, DDMMYY10.);
informat month_year ddmmyy10.
run;

proc sql;
create table monthly_sales as
select month_year, sum(Weekly_Sales) as sales from months group by month_year;
run;

proc sgplot data=monthly_sales;
series x=month_year y=sales;
format month_year ddmmyy10.;
run;
