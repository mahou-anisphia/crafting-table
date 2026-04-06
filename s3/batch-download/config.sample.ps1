# Copy this file to config.ps1 and fill in your values.
# config.ps1 is gitignored and will not be committed.

# Path to the CSV file containing download URLs
$CSV_FILE = "C:\Users\Euphie\EuphieMagicalFile.csv"

# Name of the column in the CSV that holds the download URLs
$URL_COLUMN = "DownloadURLS"

# Directory where downloaded files will be saved
$OUTPUT_DIR = ".\output"

# (Optional) Number of parallel download jobs. Default: 4
$PARALLEL_JOBS = 4
