import asyncio
from typing import List, Any
from more_itertools import chunked
import os
from dotenv import load_dotenv
import anthropic
from functools import reduce


async def extract_text(message: Any) -> str:
    return reduce(
        lambda acc, block: acc + (block.text if block.type == "text" else ""),
        message.content,
        "",
    )


async def process_chunk(client: Any, chunk: List[str]) -> Any:
    print(f"processing chunk {len(chunk)}")

    message = await client.messages.create(
        model="claude-3-5-sonnet-20240620",
        max_tokens=4096,
        temperature=0,
        # system="You are a world-class poet. Respond only with short poems.",
        messages=[
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": f"For each of these romantic comedy films, determine, out of 100%, how much of them are romance and how much are comedy. For example, a film may be 60% romance and 40% comedy.\n\nReturn your determined value as a third column in the CSV text. A value should be in the format of \"60,40\", for the 2 percentages. Make sure they're surrounded by quotes, so it's a valid CSV file. Try and spread out your assessments so that there's a wide variation. Only return the result.\n\n{chunk}",
                    }
                ],
            }
        ],
    )

    text_content = await extract_text(message)

    return text_content


async def process_file(
    client: Any,
    input_file: str,
    output_file: str,
    chunk_size: int,
):
    # Read the text file, extract header, and create chunks using more-itertools
    with open(input_file, "r") as file:
        header = file.readline().strip()  # Read and store the first line as header
        header += ",Rank"  # Add the header for the new column, that'll be added
        lines = file.readlines()
        chunks = list(chunked(lines, chunk_size))

    # Process chunks concurrently
    tasks = [process_chunk(client, chunk) for chunk in chunks]
    results = await asyncio.gather(*tasks)

    # Write results to the output file, including the header
    with open(output_file, "w") as f:
        f.write(f"{header}\n")  # Write the header first
        for result in results:
            f.write(f"{result}\n")


async def main():
    # Load environment variables from .env file
    load_dotenv()

    # Get the API key from the environment variable
    api_key = os.getenv("ANTHROPIC_API_KEY")

    # Initialize the Anthropic client with the API key
    client = anthropic.AsyncAnthropic(api_key=api_key)

    input_file = "data/films-filtered-claude.csv"
    output_file = "data/films-filtered-claude-ranked.csv"
    await process_file(client, input_file, output_file, 25)


if __name__ == "__main__":
    asyncio.run(main())
