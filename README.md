
# Analyzing Health Insurance Data Stored in a PL/SQL MySQL Database

## Project Overview:

This repository was created for the INFO 606 course at Drexel University, Advanced Database Management.  The overall goal of this project was to use Python to analyze health insurance data stored in a PL/SQL database.  This goal was achieved by creating a MySQL database using [Heroku](https://heroku.com) and ClearDB.  This repository contains SQL scripts to create the database locally.  Ensure the MySQL connection string matches your local database.  

ClearDB does not allow for the creation of PL/SQL procedures, functions, or triggers on a shared cluster.  A dedicated cluster was not feasible to purchase for educational purposes, so the project was split into two parts:

- **Part 1:** Use Python to analyze time series data from a MySQL ClearDB+Heroku set up.  
- **Part 2:** Implement the same database with a local Oracle configuration in order to create PL/SQL procedures, functions, and triggers.

## File Manifest: 
- `Folder /data` - Contains insurance data in Excel format
    - `FinalProject_Data_v1_5_mySQL.xlsx` - Contains data used to make MySQL scripts
    - `FinalProject_Data_v1_5_oracle.xlsx` - Contains data used to make oracle scripts
    - `train.csv` - Processed total monthly allowed charges for approved claims used for training. Jan 2015 - Dec 2020.
    - `test.csv` - Processed total monthly allowed cahrges for approved claims used for testing.  Jan 2021 - Dec 2021.
    - `Data_Dictionary.xlsx` - Contains data dictionary for both MySQL and Oracle
- `Folder /documents` - Contains all miscellaneous documents
    - `Project Rubric.pdf` - Rubric for class
    - `Proposal.docx` - Initial project proposal, required for class
- `Folder /sql_scripts` - Contains all SQL scripts for creating database in MySQL or Oracle.
    - `mysql_step01_initial_ddl.sql` - MySQL script to create relational database schema.
    - `mysql_step02_insert_data_claim_fact.sql` - MySQL script to populate `claim_fact` table.
    - `mysql_step03_insert_data_all_others.sql` - MySQL script to populate remaining tables.
    - `oracle_step01_initial_ddl.sql` - Oracle SQL script to create relational database schema.
    - `oracle_step02_insert_data_claim_fact.sql` - Oracle SQL script to populate `claim_fact` table.
    - `oracle_step03_insert_data_all_others.sql` - Oracle SQL script to populate remaining tables.
    - `oracle_step04_plsql.sql` - Oracle SQL script containing PL/SQL triggers, procedures, and functions.
- `database_info.py` - Python file containing connection string to avoid exposing login credentials
- `health_insurance.ipynb` - Main Python/SQL code that analyzes insurance MySQL data.

## Reason for Project:



## Team Members:

Our team consisted of the following individuals (alphabetized by last name): 

- Zach Carlson, zc378@drexel.edu
- Katy Matulay, km3868@drexel.edu
- Jacob Stank, js4977@drexel.edu
- Jacob William, jjw324@drexel.edu

## Project Requirements

- Heroku account
- [MySQL Workbench](https://www.mysql.com/products/workbench/)

## Python Requirements
- Python ≥ 3.8. 
- Python libraries required: 
    - `matplotlib.pylot`
    - `pandas`
    - `sqlalchemy`
 - `database_info.py` file (See **Config File** Section)

## How to Execute Notebook: 

**A local database instance must be created in order to execute this Jupyter Notebook.  Replace the connection string in the `database_info.py` file.** (See **`database_info.py` File** Section)  All of the code in this project needs to be opened in a Jupyter notebook environment. We recommend using [Anaconda](https://www.anaconda.com/products/individual).  Additionally, this code can be run in Google Colab or your preferred Python coding environment, assuming folder organization remains unchanged.

## Database Setup:

1. Create a Heroku app with a ClearDB plugin by following this [tutorial](https://youtu.be/aEm0BN493sU).  This tutorial will walk you through setting up your Heroku app, attaching a ClearDB plugin, and accessing the database through MySQL Workbench.  You will be required to add your credit card information, however, if you select the "free" ClearDB tier, **you will not be charged.**  Due to the size of our database, we used the "punch" ClearDB tier.
2. After logging into MySQL Workbench, click `File > Open SQL Script` and open `mysql_step01_initial_ddl.sql`.  Select all the text and click the lightning icon to run the selection.
3. After creating the tables, click `File > Open SQL Script` and open `mysql_step02_insert_data_claim_fact.sql`.  Select all the text and click the lightning icon to run the selection.  Repeat this process for `mysql_step03_insert_data_all_others.sql`.

**NOTE**:  With the free tier of ClearDB you have at most 3,600 queries/hour and a maximum storage space of 1MB.  If you use a truncated version of this data (i.e. 10 rows), you can still replicate it.  However, if you want to use the entire dataset provided, you will need to pay for the "punch" tier.  If you run into issues accessing the database or running queries, you most likely have reached the query or storage capacity cap.

4. To implement the PL/SQL functionality, create a local Oracle database and use the four SQL scripts with the prefix `oracle_` saved in the `sql_scripts` folder.

## `database_info.py` File

You can use a `database_info.py` to store your database connection string.  Add this to your `.gitignore` to avoid accidentally committing your login information onto a public repository.  Simply replace the `<>` variable placeholders with your login information.  To see which databases are allowed, click [here](https://docs.sqlalchemy.org/en/14/core/engines.html).

## Known Limitations of Project:

- **Scrambled identifiers.**  While essential to protect the identity of members and providers, knowing the true provider names would help answer some interesting questions regarding allowed charges by providers.
- **Too expensive for personal use.** Hosting MySQL data larger than 1 MB with PL/SQL units on Heroku costs upwards of $50.00/month as a dedicated server is required.  This isn't ideal for someone developing a project on their own or for a team with a very restrictive budget.
- **Predictions are not as accurate as possible.** The model's predictions for the values of 2021 were less than ideal.  Additional model configuration or trying a new model (such as linear regression) might be worthwhile.
- **The database has no table for abbrievation values.** The claim status and type are defined by word-of-mouth.  It would be best to implement a quick table outline the true values for these one-letter values.