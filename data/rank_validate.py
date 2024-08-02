import csv


def check_rank_sum(filename):
    with open(filename, "r") as file:
        csv_reader = csv.DictReader(file)

        for row in csv_reader:
            rank = row["Rank"].replace('"', "").split(",")
            rank_sum = sum(int(r) for r in rank)
            if rank_sum != 100:
                print(f"Error in row: {row['Title']} - Rank sum is {rank_sum}")
            # else:
            #     print(f"Correct: {row['Title']} - Rank sum is 100")


def main():
    output_file = "data/films-filtered-claude-ranked.csv"
    check_rank_sum(output_file)


if __name__ == "__main__":
    main()
