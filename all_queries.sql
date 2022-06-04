-- 3.1
select name from Programm;

select p.title as title_of_project                                                                                  
from project p 
inner join stelehos s on p.stelehos_id = s.stelehos_id 
where s.name like '%' and p.duration > 0 and ((p.beginning < current_date())  and (p.ending > current_date()));

select name_of_researcher from (
(select concat(r.last_name," ", r.first_name) as name_of_researcher, p.title 
from researcher r 
inner join works_in_project wip on r.researcher_id = wip.researcher_id 
inner join project p on wip.project_id = p.project_id
order by name_of_researcher)
union 
(select concat(r.last_name," ", r.first_name) as name_of_researcher, p.title 
from researcher r 
inner join project p on r.researcher_id = p.supervisor_id 
order by name_of_researcher)) A
where A.title = '%';

-- 3.2
create view projects_per_researcher as
(select concat( r.last_name," ", r.first_name ) as researcher_name, p.title as project_title 
from Researcher r 
inner join Works_in_Project wip on r.researcher_id = wip.researcher_id 
inner join Project p on wip.project_id = p.project_id  )
union all 
(select concat(r.last_name," ", r.first_name) as researcher_name, p.title as project_title 
from Researcher r 
inner join Project p on r.researcher_id = p.supervisor_id )
order by researcher_name ;

select * from projects_per_researcher;

create view projects_per_organisation as 
select o.name as organisation_name, p.title as project_title 
from Organisation o 
inner join Project p on o.organisation_id = p.organisation_id 
order by organisation_name ;

select * from projects_per_organisation;

drop view projects_per_researcher;
drop view projects_per_organisation;

-- 3.3
(select p.title, r.last_name, r.first_name  
from Researcher r 
inner join Works_in_Project wip on r.researcher_id = wip.researcher_id 
inner join Project p on wip.project_id = p.project_id 
inner join Project_Research_Field prf on p.project_id = prf.project_id
where (prf.name = 'History')
and ((p.beginning < current_date())  and (p.ending > current_date())))
union 
(select p.title, r.last_name, r.first_name  
from Researcher r 
inner join Project p on r.researcher_id = p.supervisor_id 
inner join Project_Research_Field prf on p.project_id = prf.project_id 
where (prf.name = 'History')
and ((p.beginning < current_date())  and (p.ending > current_date())));

-- 3.4

create view orgs_projects_per_year as
select name, extract( year from beginning) as yearr, count(*) as got_projects from (
select o.name, p.project_id , p.beginning
from Organisation o 
inner join Project p on p.organisation_id = o.organisation_id ) A
group by  yearr, name ;

select name, a_year, next_year, a_got_projects as number_of_projects  from (
select a.name, a.yearr as a_year, a.got_projects as a_got_projects, b.yearr as next_year, b.got_projects as other_year_got_projects 
from orgs_projects_per_year a
inner join orgs_projects_per_year b on a.name = b.name
where a.yearr != b.yearr and a.yearr < b.yearr) A 
where (next_year - a_year = 1) and a_got_projects = other_year_got_projects and a_got_projects >= 10; 

drop view orgs_projects_per_year;

--3.5
create view project_and_rf as
select p.title, p.project_id, prf.name  
from Project p 
inner join Project_Research_Field prf on p.project_id = prf.project_id 
order by p.project_id ;

select title, project_id, rf_duo, count(*) as counter from (
select prf1.title, prf1.project_id, concat (prf1.name," ", prf2.name) rf_duo
from project_and_rf prf1 
inner join project_and_rf prf2 on prf1.title = prf2.title
where prf1.name != prf2.name and prf1.name < prf2.name) A 
group by rf_duo
order by counter desc
limit 3;

drop view project_and_rf;

-- 3.6
create view active_projects as
	select * from Project p 
	where ((p.beginning < current_date())  and (p.ending > current_date()));	


(select r.last_name, r.first_name, count(*) as projects_working_on 
from Researcher r 
inner join Works_in_Project wip on r.researcher_id = wip.researcher_id 
inner join active_projects ap on wip.project_id = ap.project_id 
where r.date_of_birth > '1981-12-31'
group by r.last_name)
union 
(select r.last_name, r.first_name, count(*) as projects_working_on 
from Researcher r 
inner join active_projects ap on r.researcher_id  = ap.supervisor_id
where r.date_of_birth > '1981-12-31' 
group by r.last_name ) 
order by projects_working_on desc ;

drop view active_projects;

-- 3.7
create view projects_of_companies as
select sum(p.amount) as total_amount, p.title, p.project_id, p.stelehos_id, p.programm_id, p.organisation_id, o.name 
from Project p inner join Company c on p.organisation_id = c.organisation_id 
inner join Organisation o on o.organisation_id = c.organisation_id 
group by p.stelehos_id, o.name;

select s.name, pc.name, pc.total_amount  
from projects_of_companies pc 
inner join Stelehos s on pc.stelehos_id = s.stelehos_id 
order by pc.total_amount desc 
limit 5;

drop view projects_of_companies;

-- 3.8
select * from (
select concat(last_name, " ", first_name) as name_of_researcher, count(*) as projects_working_on  from (
(select r.last_name, r.first_name
from researcher r 
inner join works_in_project wip on r.researcher_id = wip.researcher_id 
inner join project p on wip.project_id = p.project_id 
left join delivered d on p.project_id = d.project_id 
where d.title is null )
union all
(select r.last_name, r.first_name
from researcher r 
inner join project p on r.researcher_id  = p.supervisor_id
left join delivered d on p.project_id = d.project_id 
where d.title is null  ) ) A
group by A.last_name ) B
where projects_working_on >= 5
order by projects_working_on desc;