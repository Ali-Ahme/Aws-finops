# AWS Resource Optimization Script

This script identifies unused or rarely accessed AWS resources to help optimize cloud costs, including:

- **EC2 Instances**: Detects running instances inactive for over 90 days.
- **S3 Buckets**: Lists buckets without logging activity.
- **RDS Instances**: Finds RDS instances that have had no connections for 90 days.
- **EBS Volumes**: Reports unattached volumes for potential deletion.

## Requirements

- AWS CLI installed and configured.
- Bash shell environment.

## Usage

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/aws-resource-optimization.git
   cd aws-resource-optimization
