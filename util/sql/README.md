# `SQLite` QADB

This is an idea for an alternative storage option for the QADB, as a `SQLite`
database. You can convert charge trees from json to sqlite and vice versa with
```bash
run-groovy ChargeTreeToSQLite.groovy [dataset] [chargeTree_path]
run-groovy SQLiteToChargeTree.groovy [dataset] [db_path]
```

You can also convert JSON databases to and from SQL with the remaining scripts
```bash
run-groovy JSONToSQLite.groovy [dataset] [qaTree_path] [useFT]
run-groovy SQLiteToJSON.groovy [dataset] [db_path] [useFT]
```
