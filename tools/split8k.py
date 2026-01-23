#!/usr/bin/env python3

import os
import sys

def split_file(file_path, chunk_size=8192):
    if not os.path.isfile(file_path):
        print(f"Error: File {file_path} does not exist.")
        return

    file_name, file_extension = os.path.splitext(file_path)
    with open(file_path, 'rb') as f:
        chunk_num = 0
        while True:
            chunk = f.read(chunk_size)
            if not chunk:
                break
            chunk_file_name = f"{file_name}_{chunk_num}{file_extension}"
            with open(chunk_file_name, 'wb') as chunk_file:
                chunk_file.write(chunk)
            chunk_num += 1
            print(f"Created {chunk_file_name}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python split8k.py <binary_file_path>")
        sys.exit(1)

    binary_file_path = sys.argv[1]
    split_file(binary_file_path)