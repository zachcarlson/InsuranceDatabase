
# Analyzing Health Insurance Data Stored in a PL/SQL MySQL Database

## Project Overview:

This repository was created for the INFO 606 course at Drexel University, Advanced Database Management.  The overall goal of this project was to use Python to analyze health insurance data stored in a PL/SQL database.  This goal was achieved by creating a MySQL database using Heroku and ClearDB.  This repository contains SQL scripts to create the database locally.  Ensure the MySQL connection string matches your local database.  

## File Manifest: 

- `Folder /data` - Contains all data files
    - `health_insurance.xlsx` - Raw insurance data 
- `Folder /documents` - Cotains all miscellaneous documents
- `Folder /sql_scripts` - Contains all SQL scripts for creating database in MySQL Workbench.
    - `create_tables.sql` - SQL script to create relational database schema.
    - `insert_data.sql` - SQL script to populate database tables.
- `health_insurance.ipynb` - Main Python/SQL code that analyzes insurance MySQL data.

## Reason for Project:



## Team Members:

Our team consisted of the following individuals (alphabetized by last name): 

- Zach Carlson, zc378@drexel.edu
- Katy Matulay, km3868@drexel.edu
- Jacob Stank, js4977@drexel.edu
- Jacob William, jjw324@drexel.edu

## Python Requirements
- Python ≥ 3.8. 
- Python libraries required: 
    - `matplotlib.pylot`
    - `pandas`
    - `ipython-sql`
    - `mysqlclient`
   
## How to Execute Code: 

**A local database instance must be created in order to execute this Jupyter Notebook.  Replace the connection string in the appropriate cell with your database and login information.**  All of the code in this project needs to be opened in a Jupyter notebook environment. We recommend using [Anaconda](https://www.anaconda.com/products/individual).  Additionally, this code can be run in Google Colab or your preferred Python coding environment, assuming folder organization remains unchanged.

## Known Limitations of Project:

