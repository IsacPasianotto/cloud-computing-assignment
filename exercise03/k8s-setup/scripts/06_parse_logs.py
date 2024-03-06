import csv

def parse_logs(input_file, output_file):
    data = []

    with open(input_file, 'r') as f:
        current_section = None
        for line in f:
            line = line.strip()
            if line.startswith("# OSU MPI Allgather Latency Test"):
                current_section = line.strip()
            elif 'MPI_CHAR' in line:
                next(f)  # Skip the header line
                for line in f:
                    line = line.strip()
                    if line.startswith("#"):
                        break
                    size, latency = map(float, line.split())
                    data.append((int(size), latency))

    with open(output_file, 'w', newline='') as csvfile:
        csv_writer = csv.writer(csvfile)
        csv_writer.writerow(['Size', 'Latency(us)'])

        for size, latency in data:
            csv_writer.writerow([size, latency])

if __name__ == "__main__":
    import sys

    if len(sys.argv) != 3:
        print("Usage: python 06_parse_logs.py input_file output_file.csv")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    parse_logs(input_file, output_file)
    print(f"CSV file generated: {output_file}")
