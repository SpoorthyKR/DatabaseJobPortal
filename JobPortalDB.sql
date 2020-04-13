/* SPOORTHY K RAJASHEKAR
    No : n01408024
	NET-011-505
	ASSIGNMENT 1
	Sub :  Db Design & Data Qry-Sql Server*/

	use JOB_PORTAL_DB
	go

/*1. Identify the users who logon before 2017 but never logon during 2017. Eliminate duplicate lines 
     from your output.
Output Colums: User Login, User Name, User Phone Order by: User Login*/

SELECT DISTINCT SL.Login as 'User Login',
SL.Full_Name as 'User Name', 
SL.Phone_Number as 'User Phone'
FROM Security_Logins as SL LEFT OUTER JOIN Security_Logins_Log as SLL
ON SL.Id = SLL.Login and  Year(SLL.Logon_Date) < 2017
WHERE Year(SLL.Logon_Date) IS NOT NULL
EXCEPT
SELECT DISTINCT SL.Login as 'User Login', SL.Full_Name as 'User Name', SL.Phone_Number as 'User Phone'
FROM Security_Logins as SL 
LEFT OUTER JOIN Security_Logins_Log as SLL
ON SL.Id = SLL.Login and  Year(SLL.Logon_Date) > 2016
WHERE Year(SLL.Logon_Date) IS NOT NULL
ORDER BY 'User Login';

/*2. Identify the companies where applicants applied for the job 10 or more times. 
Eliminate duplicate lines from your output.
Output Colums : Company Name (English only)
Order by: Company Name
*/
WITH C AS
(
	SELECT DISTINCT c.Company FROM Company_Jobs AS c
	LEFT OUTER JOIN Applicant_Job_Applications AS d
	ON c.Id = d.Job
	GROUP BY c.Company
	HAVING COUNT(d.Job)>=10
)
SELECT A.Company_Name AS 'Company Name' FROM Company_Descriptions AS A
RIGHT OUTER JOIN C
ON A.Company = C.Company
WHERE A.LanguageID = N'EN'
ORDER BY 'Company Name'

/*3. Identify the Applicants with highest current salary for each Currency.
      Output Colums : Applicant Name, Current Salary, Currency*/

SELECT TOP(1) WITH TIES sl.Full_Name AS 'Applicant Name',
 ap.Current_Salary AS 'Current Salary', ap.Currency
FROM Applicant_Profiles AS ap
LEFT OUTER JOIN Security_Logins AS sl
ON ap.Login = sl.Id
ORDER BY ap.Current_Salary * ap.Current_Rate DESC

/*4. For each company, determine the number of jobs posted. If a company doesn't have posted jobs,
     show 0 for that company.
Output Colums : Company Name,  #Jobs Posted (show 0 if none)
Order by: #Jobs Posted*/
;WITH C AS
(
	SELECT DISTINCT c.Company, COUNT(c.Id) AS 'Number of Jobs' FROM Company_Jobs AS c
	LEFT OUTER JOIN Company_Jobs_Descriptions AS d
	ON c.Id = d.Job
	GROUP BY c.Company
)
SELECT A.Company_Name AS 'Company Name', ISNULL(C.[Number of Jobs],0) AS '#Jobs Posted'
FROM Company_Descriptions AS A
LEFT OUTER JOIN C
ON A.Company = C.Company
WHERE A.LanguageID = N'EN'
ORDER BY '#Jobs Posted'

/*5. Determine the total number of companies that have posted jobs and the total number of companies
that has never posted jobs in one data set with 2 rows
 like the one below:
Clients with Posted Jobs:	 NNN
Clients without Posted Jobs:	 NNN
*/
;WITH C AS
(
	SELECT DISTINCT Company_Descriptions.Company 
	FROM Company_Descriptions
	EXCEPT
	SELECT DISTINCT Company_Jobs.Company 
	FROM Company_Jobs
)
SELECT 'Clients with Posted Jobs:', COUNT(DISTINCT Company_Jobs.Company) AS 'Number'
FROM Company_Jobs
UNION
SELECT 'Clients without Posted Jobs:', COUNT(DISTINCT C.Company)
FROM C	
