########################################
########################################
#./condense.py
########################################
########################################


#! /usr/bin/env python3
"""
# Add to your path by 
ln -s /path/to/condense.py /usr/local/bin/condense

# Call it 
condense <filetype> 

"""
import argparse
import os

# Dictionary mapping file types to comments
COMMENTS = {
    'py': '#',
    'swift': '//',
    'rs': '//',
    'kt': '//',
    'java': '//',
    'js': '//',
    'ts': '//',
}

def merge_files(file_type, max_depth=1):
    output_file = 'Condensed.' + file_type
    # Delete output_file if it exists
    if os.path.exists(output_file):
        os.remove(output_file) 
    if file_type not in COMMENTS:
        raise ValueError(f"Sorry, we don't support the {file_type} file type.")

    # Initialize an empty list to store the file paths and contents
    files = []

    # Use os.walk to traverse the directory tree and retrieve the file paths
    for dirpath, dirnames, filenames in os.walk('.', topdown=True):
        dirnames[:] = [d for d in dirnames if os.path.join(dirpath, d).count(os.sep) - dirpath.count(os.sep) <= max_depth]
        for filename in filenames:
            if filename.endswith(file_type):
                file_path = os.path.join(dirpath, filename)
                with open(file_path) as f:
                    file_contents = f.read()
                files.append((file_path, file_contents))

    # Write the file paths and comments to a single output file
    with open(output_file, 'w') as f:
        for file_path, file_contents in files:
            comment_str = COMMENTS[file_type]
            decoration = comment_str * 40 + "\n"
            f.write(decoration * 2)
            f.write(comment_str + file_path + "\n")
            f.write(decoration * 2  + "\n" * 2)

            f.write(file_contents + "\n" * 2)

            f.write(decoration * 2)
            f.write(comment_str + " END " + file_path + "\n")
            f.write(decoration * 2  + "\n" * 2)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('file_type', choices=COMMENTS.keys(), help='the file type to merge')
    parser.add_argument('-d', '--max_depth', type=int, default=1, help='the maximum depth to search for files')
    args = parser.parse_args()

    try:
        merge_files(args.file_type, args.max_depth)
    except ValueError as e:
        print(e)


########################################
########################################
# END ./condense.py
########################################
########################################


