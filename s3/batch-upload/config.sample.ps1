# Copy this file to config.ps1 and fill in your values.
# config.ps1 is gitignored and will not be committed.

# AWS CLI profile to use (leave as "default" to use the default profile)
$AWS_PROFILE = "euphie"

# Target S3 bucket name (without s3:// prefix)
$S3_BUCKET = "euphie-bucket"

# Key prefix (folder path) inside the bucket. Use "" for the bucket root.
# Example: "uploads/2024/" or "assets/images"
$S3_PREFIX = "uploads/"

# Local directory whose contents will be uploaded
$LOCAL_DIR = "C:\Users\Euphie\EuphieMagicalFiles"

# (Optional) Extra aws s3 sync / cp flags, e.g. "--acl public-read" or "--sse AES256"
$EXTRA_FLAGS = ""

# (Optional) Set to $true to do a dry-run (--dryrun) without actually uploading
$DRY_RUN = $false
