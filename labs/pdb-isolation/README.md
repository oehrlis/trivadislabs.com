# Test and Demo Scripts

This directory contains the test and demo scripts for PDB isolation and security. The scripts are *self contained*. They do expect to run in a PDB named *PDBSEC* with an admin user *PDBADMIN*. The initial script `10_create_pdb.sql` does create a corresponding PDB. Alternatively the script acept as parameter the `<PDBNAME>`, `<PDBADMIN>`, `<PDBPASSWORD>`. The following table provide a short overview of the different scripts.

| Script Name                                                        | Type | Description                                                                                     |
|--------------------------------------------------------------------|------|-------------------------------------------------------------------------------------------------|
| [00_prepare_pdb_env.sh](00_prepare_pdb_env.sh)                     | bash | Preparation script to add PDB OS user used for the OS call tests.                               |
| [01_add_pdb_os_user.sh](01_add_pdb_os_user.sh)                     | bash | Script to add a tnsname entry for the PDB PDBSEC                                                |
| [10_create_pdb.sql](10_create_pdb.sql)                             | SQL  | Create a PDB (pdbsec) used for PDB security engineering                                         |
| [20_create_directories.sql](20_create_directories.sql)             | SQL  | Create and test Oracle directories with and without PATH_PREFIX                                 |
| [30_create_datafile.sql](30_create_datafile.sql)                   | SQL  | Script to test tablespace / datafile creation with different locations                          |
| [40_create_PDB_OS_CREDENTIAL.sql](40_create_PDB_OS_CREDENTIAL.sql) | SQL  | Script to configure PDB_OS_CREDENTIAL                                                           |
| [41_create_ext_table.sql](41_create_ext_table.sql)                 | SQL  | Verify script test and configure table pre-processors                                           |
| [42_create_scheduler_job.sql](42_create_scheduler_job.sql)         | SQL  | Script to configure and test external OS jobs using DBMS_SCHEDULER                              |
| [50_create_lockdown_profiles.sql](50_create_lockdown_profiles.sql) | SQL  | Script to create lockdown profiles                                                              |
| [51_verify_lockdown_profiles.sql](51_verify_lockdown_profiles.sql) | SQL  | Script to verify the lockdown profiles. Execute a couple of allowed and not allowed statements. |
| [60_dbms_sys_sql_test.sql](60_dbms_sys_sql_test.sql)               | SQL  | Script to verify if DBMS_SYS_SQL can be used as PDBADMIN                                        |
| [90_drop_pdb.sql](90_drop_pdb.sql)                                 | SQL  | Drop PDB (pdbsec) used for PDB security engineering                                             |
| [ld_profiles.sql](ld_profiles.sql)                                 | SQL  | Displays information about lockdown profiles.                                                   |
| [ld_rules.sql](ld_rules.sql)                                       | SQL  | Displays information about lockdown rules in the current container                              |