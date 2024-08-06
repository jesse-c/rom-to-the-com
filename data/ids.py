import asyncio
from typing import List
import uuid
import csv


async def process_chunk(chunk: List[str]) -> List[tuple]:
    print(f"processing chunk {len(chunk)}")

    results = []
    for line in chunk:
        new_uuid = str(uuid.uuid4())
        results.append((new_uuid, line.strip()))

    return results


async def process_file(
    input_file: str,
    output_file: str,
    chunk_size: int,
):
    # Read the text file, extract header, and create chunks
    with open(input_file, "r") as file:
        header = file.readline().strip()  # Read and store the first line as header
        header = f"ID,{header}"  # Add the header for the new ID column
        lines = file.readlines()
        chunks = [lines[i : i + chunk_size] for i in range(0, len(lines), chunk_size)]

    # Process chunks concurrently
    tasks = [process_chunk(chunk) for chunk in chunks]
    results = await asyncio.gather(*tasks)

    # Flatten the results
    flat_results = [item for sublist in results for item in sublist]

    # Write results to the output file, including the header
    with open(output_file, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(header.split(","))  # Write the header first
        for id, line in flat_results:
            row = [id] + line.split(",")
            writer.writerow(row)


async def main():
    input_file = "films-filtered-claude-ranked.csv"
    output_file = "films-filtered-claude-ranked-ids.csv"

    await process_file(input_file, output_file, 25)


if __name__ == "__main__":
    asyncio.run(main())
