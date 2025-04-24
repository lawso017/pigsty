#!/bin/bash
# gen-envrc.sh - Generates a .envrc file from .env.template with random values

set -e

# Check if template exists
if [ ! -f .env.template ]; then
  echo "Error: .env.template not found"
  exit 1
fi

# Create output file
output_file=".envrc"
echo "# Generated .envrc file with random values" > "$output_file"
echo "# Generated on $(date)" >> "$output_file"
echo "" >> "$output_file"

# Process each line
while IFS= read -r line; do
  # Skip comments and empty lines
  if [[ "$line" =~ ^#.*$ || -z "$line" ]]; then
    echo "$line" >> "$output_file"
    continue
  fi
  
  # Handle export variable assignments
  if [[ "$line" =~ ^export[[:space:]]+([A-Za-z0-9_]+)= ]]; then
    var_name="${BASH_REMATCH[1]}"
    # Generate 30-character random base64 string
    random_value=$(openssl rand -base64 30 | tr -d '/+=' | cut -c1-30)
    echo "export $var_name=$random_value" >> "$output_file"
  else
    # Copy line as-is if not a variable assignment
    echo "$line" >> "$output_file"
  fi
done < .env.template

# Add direnv command to source other files if needed
echo "" >> "$output_file"
echo "# Load standard environment if exists" >> "$output_file"
echo "[ -f .env ] && source_env .env" >> "$output_file"

# Make output readable only by owner for security
chmod 600 "$output_file"

echo "Created $output_file with random values"
echo "Remember to run 'direnv allow' to approve the new .envrc file"
