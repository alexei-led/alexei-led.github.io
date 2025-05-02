#!/bin/bash

# Directory containing posts
POSTS_DIR="/Users/alexei/Workspace/blog/_posts"

# Process each markdown file
for file in "$POSTS_DIR"/*.md; do
  filename=$(basename "$file")
  
  # Skip files that already match the pattern (YYYY-MM-DD-*.md)
  if [[ $filename =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}-.*\.md$ ]]; then
    echo "Skipping already correctly named file: $filename"
    continue
  fi
  
  # Extract date from the file
  date_line=$(grep -m 1 "date:" "$file")
  if [[ -z "$date_line" ]]; then
    echo "No date found in $filename, skipping..."
    continue
  fi
  
  # Extract the date part in YYYY-MM-DD format
  date_part=$(echo "$date_line" | grep -o "[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}")
  if [[ -z "$date_part" ]]; then
    echo "Could not extract date from $filename, skipping..."
    continue
  fi
  
  # Convert original filename to kebab-case
  new_basename=$(echo "${filename%.*}" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')
  
  # Create the new filename
  new_filename="${date_part}-${new_basename}.md"
  new_filepath="$POSTS_DIR/$new_filename"
  
  # Rename the file
  mv "$file" "$new_filepath"
  echo "Renamed: $filename -> $new_filename"
done

echo "Post renaming complete!"
