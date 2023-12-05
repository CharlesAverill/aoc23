import re

def find_calibration_values(calibration_document):
    # Initialize the sum of calibration values
    total_sum = 0

    # Regular expression to extract word digits and numeric digits from the lines
    digit_pattern = re.compile(r'(one|two|three|four|five|six|seven|eight|nine|\d)')

    # Dictionary mapping word digits to numeric digits
    word_digit_mapping = {
        'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5,
        'six': 6, 'seven': 7, 'eight': 8, 'nine': 9
    }

    # Iterate through each line in the calibration document
    for line in calibration_document:
        # Extract all the word digits and numeric digits from the line
        digit_matches = digit_pattern.findall(line)

        # Convert word digits to numeric digits using the mapping
        digits = [word_digit_mapping.get(match, match) for match in digit_matches]

        # Add the sum of the first and last digits to the total sum
        try:
            total_sum += (10 * int(digits[0])) + int(digits[-1])
            print(line.strip(), f"{digits[0]}{digits[-1]}", total_sum)
        except:
            print(line)


    return total_sum

# Example usage:
with open('input', 'r') as file:
    calibration_document = file.readlines()

result = find_calibration_values(calibration_document)
print("Sum of calibration values:", result)
