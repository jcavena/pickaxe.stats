# README


# SQL Queries

## Lists weekly_stat_id's that no longer exist in the weekly_stats table, but have orphaned records in stats.
```
select distinct(weekly_stat_id) from stats where weekly_stat_id not in (select id from weekly_stats) order by weekly_stat_id;
```