
# Analyzing Health Insurance Data Stored in a PL/SQL MySQL Database

## Project Overview:

This repository was created for the INFO 606 course at Drexel University, Advanced Database Management.  The overall goal of this project was to use Python to analyze health insurance data stored in a PL/SQL database.  This goal was achieved by creating a MySQL database using [Heroku](https://heroku.com) and ClearDB.  This repository contains SQL scripts to create the database locally.  Ensure the MySQL connection string matches your local database.  

## File Manifest: 

- `Folder /documents` - Cotains all miscellaneous documents
- `Folder /sql_scripts` - Contains all SQL scripts for creating database in MySQL Workbench.
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

**A local database instance must be created in order to execute this Jupyter Notebook.  Replace the connection string in the appropriate cell with your database and login information. (See Database Setup)**  All of the code in this project needs to be opened in a Jupyter notebook environment. We recommend using [Anaconda](https://www.anaconda.com/products/individual).  Additionally, this code can be run in Google Colab or your preferred Python coding environment, assuming folder organization remains unchanged.

## Database Setup:

1. Create a Heroku app with a ClearDB plugin by following this [tutorial](https://youtu.be/aEm0BN493sU).  This tutorial will walk you through setting up your Heroku app, attaching a ClearDB plugin, and accessing the database through MySQL Workbench.  You will be required to add your credit card information, however, if you select the "free" ClearDB tier, **you will not be charged.**  Due to the size of our database, we used the "punch" ClearDB tier.
2. After logging into MySQL Workbench, click `File > Open SQL Script` and open `step01_ddl.sql`.  Select all the text and click the lightning icon to run the selection.
3. After creating the tables, click `File > Open SQL Script` and open `step02_insert_data.sql`.  Select all the text and click the lightning icon to run the selection.  

**NOTE**:  With the free tier of ClearDB you have at most 3,600 queries/hour and a maximum storage space of 1MB.  If you use a truncated version of this data (i.e. 10 rows), you can still replicate it.  However, if you want to use the entire dataset provided, you will need to pay for the "punch" tier.  If you run into issues accessing the database or running queries, you most likely have reached the query or storage capacity cap.

## `database_info.py` File

You can use a `database_info.py` to store your database connection string.  Add this to your `.gitignore` to avoid accidentally committing your login information onto a public repository.  Simply replace the `<>` variable placeholders with your login information.

## Known Limitations of Project:

