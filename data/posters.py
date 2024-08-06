import asyncio
import csv
import time
import os
from aiohttp import ClientSession
from dotenv import load_dotenv
import json
from datetime import datetime
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.StreamHandler()],
)


async def send_request(session, row, api_key):
    url = "https://api.themoviedb.org/3/search/movie"
    params = {"api_key": api_key, "query": row["Title"]}
    async with session.get(url, params=params) as response:
        return await response.json()


async def process_csv(csv_file, requests_per_second, api_key):
    all_results = []

    async with ClientSession() as session:
        with open(csv_file, "r") as file:
            reader = csv.DictReader(file)

            for chunk in chunks(reader, requests_per_second):
                start_time = time.time()

                tasks = [send_request(session, row, api_key) for row in chunk]
                chunk_results = await asyncio.gather(*tasks)

                all_results.extend(chunk_results)

                elapsed_time = time.time() - start_time

                # Force a minimum of a second
                if elapsed_time < 1:
                    await asyncio.sleep(1 - elapsed_time)

    return all_results


def chunks(iterable, size):
    chunk = []
    for item in iterable:
        chunk.append(item)
        if len(chunk) == size:
            yield chunk
            chunk = []
    if chunk:
        yield chunk


def append_image(input_file, output_file, results):
    with (
        open(input_file, "r", newline="") as infile,
        open(output_file, "w", newline="") as outfile,
    ):
        reader = csv.DictReader(infile)

        new_column_name = "Poster"

        # Get the fieldnames from the reader and add the new column name
        fieldnames = reader.fieldnames + [new_column_name]

        writer = csv.DictWriter(outfile, fieldnames=fieldnames)
        writer.writeheader()

        for index, row in enumerate(reader):
            image = find_image(row, results[index])
            match image:
                case None:
                    row[new_column_name] = ""
                case str():
                    row[new_column_name] = image

            writer.writerow(row)

    logging.info(f"processing complete, output written to {output_file}")


def find_image(row, result):
    for item in result["results"]:
        title = item["title"]

        if "release_date" not in item:
            continue

        if item["release_date"] == "":
            continue

        date_object = datetime.strptime(item["release_date"], "%Y-%m-%d")
        release_date = date_object.year

        if title == row["Title"] and release_date == int(row["Year"]):
            return item["poster_path"]

    return None


async def main():
    # Load environment variables from .env file
    load_dotenv()

    api_key = os.getenv("TMDB_API_KEY")

    input_file = "films-filtered-claude-ranked-ids.csv"
    output_file = "films-filtered-claude-ranked-ids-images.csv"
    responses_file = "films-filtered-claude-ranked-ids.jsonl"

    if os.path.exists(responses_file):
        logging.info("loading responses")

        results = []
        with open(responses_file, "r") as file:
            for line in file:
                results.append(json.loads(line.strip()))
    else:
        logging.info("getting responses")

        results = await process_csv(input_file, 25, api_key)

        with open(responses_file, "w") as file:
            for response in results:
                json_string = json.dumps(response)
                file.write(json_string + "\n")

    logging.info("got responses")

    append_image(input_file, output_file, results)


if __name__ == "__main__":
    asyncio.run(main())
