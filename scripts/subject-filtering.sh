ROOT_DIR="/devops"
PROJECT_DIR="$ROOT_DIR/projects"
SCRIPT_DIR="$ROOT_DIR/scripts"
TMP_DIR="$ROOT_DIR/tmp"

for PROJECT_PATH in "$PROJECT_DIR"/*/; do
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

    java -Xmx4000m -jar tools/coupling.jar "-project_prefix" "$PACKAGE" "-project_cp" "$CPS" "-out_dir" "$TMP_DIR/$PROJECT"
done

python "$SCRIPT_DIR/make-final-csv.py"

rm -rf "$TMP_DIR"
