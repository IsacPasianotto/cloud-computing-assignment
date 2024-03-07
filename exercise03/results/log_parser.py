import os
import csv

OUTPUT_FILE = "combined_data.csv"

def parse_logs(input_file, output_file, benchmark_name):
    data = []
    try:
        with open(input_file, 'r') as f:
            current_section = None
            for line in f:
                line = line.strip()
                if line.startswith("# OSU MPI"):
                    current_section = line.strip()
                elif 'MPI_CHAR' in line:
                    # Skip the header line
                    next(f)  
                    for line in f:
                        line = line.strip()
                        if line.startswith("#"):
                            break
                        values = line.split()
                        if len(values) == 2:
                            size, latency = map(float, values)
                            data.append((int(size), latency, benchmark_name))
                        else:
                            pass
    except Exception as e:
        print(f"Error processing {input_file}: {e}")

    with open(output_file, 'a', newline='') as csvfile:
        csv_writer = csv.writer(csvfile)
        for size, latency, benchmark in data:
            csv_writer.writerow([size, latency, benchmark])

def process_logs_in_current_directory():
    with open(OUTPUT_FILE, 'w', newline='') as csvfile:
        csv_writer = csv.writer(csvfile)
        csv_writer.writerow(['Size', 'Latency(us)', 'Benchmark'])

        for filename in os.listdir(os.getcwd()):
            if filename.endswith(".log"):
                benchmark_name = os.path.splitext(filename)[0]
                input_file = os.path.join(os.getcwd(), filename)
                parse_logs(input_file, "combined_data.csv", benchmark_name)

if __name__ == "__main__":
    process_logs_in_current_directory()
    print(f"CSV file generated: {OUTPUT_FILE}")
