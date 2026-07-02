# Setup Instructions

## SQL Environment
- Download and install MySQL Workbench 8.0 or above
- Create a new schema (e.g. `mmr_retail`) and select it
- Run SQL scripts in numbered order (01 → 04)
- Export resulting tables as CSV using the 
  Table Data Export Wizard

## Python Environment
- Python 3.x required
- Install dependencies:

pip install pandas seaborn matplotlib

## Execution Order
1. Run SQL scripts 01–04 in MySQL Workbench
2. Export tables as CSV into the `data/outputs/` folder
3. Run `05_analysis_and_visualisation.py`