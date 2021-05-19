/*****************************************************************
******************************************************************
** This procedure is the intellectual property  of             **
**  Westpac Banking Corporation. The unauthorised    **
** use or copying of this procedure is prohibited            **
******************************************************************
******************************************************************/

CREATE  procedure DBA_SpaceUsed
@DBName varchar(30),
@ObjectName varchar(50) = 'NULL'

AS

Declare @CmdLine nvarchar(500)
Declare @CurrentDate datetime
create table #spaceused
(	Name	varchar(100)
	,rows		varchar(50) --int null,
	,reserved	varchar(50) --dec(15) null,
	,data		varchar(50) --dec(15) null,
	,index_size	varchar(50) --dec(15) null,
	,unused		varchar(50) --dec(15) null
)

Select @CurrentDate = getdate()

select @CmdLine = N'exec '+@DBName+'.dbo.sp_MSforeachtable "INSERT INTO #spaceused
               EXEC sp_spaceused ''?''"'

exec sp_executesql @Cmdline

insert into dbadb.dbo.DBA_tblSpaceUsed(DBName,TableName, rows,reserved, data,index_size,unused, SummaryDate)
select @DBName,Name,rows,cast(replace(reserved,'kb',' ')as int),cast(replace(data,'kb',' ')as int),cast(replace(index_size,'kb',' ')as int),cast(replace(unused,'kb',' ')as int), getdate()
from #spaceused

insert into dbadb.dbo.DBA_tblSpaceUsed(DBName,TableName, rows,reserved, data,index_size,unused, SummaryDate)
select DBName, 'All', sum(rows),sum(reserved), sum(data),sum(index_size),sum(unused), SummaryDate
from dbadb.dbo.DBA_tblSpaceUsed
where DBName = @DBName
group by DBName, SummaryDate
having SummaryDate >= @CurrentDate
GO