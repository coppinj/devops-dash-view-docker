ROOT_DIR="/devops/source"

# Iterate over each project directory
for PROJECT_PATH in "$ROOT_DIR"/*/; do
    # Check if cp-entries.txt and cp-package.txt exist
    if [ ! -f "${PROJECT_PATH}/cp-entries.txt" ] || [ ! -f "${PROJECT_PATH}/cp-package.txt" ]; then
        echo "One or both of the required files are missing for project: $PROJECT_PATH"
        continue
    fi

    PROJECT=$(basename "$PROJECT_PATH")

    echo "Running coupling analysis on $PROJECT"

    CP_ENTRIES="${PROJECT_PATH}/cp-entries.txt"
    CP_PACKAGE="${PROJECT_PATH}/cp-package.txt"

    CP_ENTRIES_CONTENT=$( cat $CP_ENTRIES )
    PACKAGE=$( cat $CP_PACKAGE | head -1 )

    CPS=$( python /devops/scripts/reassemble-cps.py "$CP_ENTRIES_CONTENT" "$PROJECT")

    java -Xmx4000m -jar tools/coupling.jar "-project_prefix" "$PACKAGE" "-project_cp" "$CPS" "-out_dir" "/devops/temp-csvs/$PROJECT"
done

exit 0;

# Merge CSV files


python scripts/python/case-selection/make-final-csv.py
rm -rf temp-csvs
