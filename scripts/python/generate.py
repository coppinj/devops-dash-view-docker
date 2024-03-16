import os
import csv

data_path = "/devops/data"
selected_class_pairs_path = os.path.join(data_path, "selected-class-pairs.csv")

rounds = range(1, 3) # MAKE CONFIGURABLE

subject_path = os.path.join(data_path,"subjects.csv")

with open(subject_path, "wt") as wp:
    fieldnames = ['execution_id', 'project', 'caller_class', 'callee_class', 'type']
    writer = csv.DictWriter(wp, fieldnames=fieldnames)

    writer.writeheader()

    for execution_id in rounds:
        with open(selected_class_pairs_path, 'rt') as fp:
            csv_file_reader = csv.DictReader(fp)

            for row in csv_file_reader:
                writer.writerow({
                    "execution_id": execution_id,
                    "project": row["case"],
                    "caller_class": row["caller"],
                    "callee_class": row["callee"],
                    "type": row["type"]
                })
