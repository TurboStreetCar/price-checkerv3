# filename of the text file
file_name = "/logs/testlog.log"

# text to be added (using \n for a new line)
text_to_append = "This is a new line added to the file.\n"

try:
    # 'a' mode: Open for appending (creates file if it doesn't exist)
    # encoding='utf-8' ensures correct character handling
    with open(file_name, "a", encoding="utf-8") as file:
        file.write(text_to_append)
    
    print(f"Successfully appended text to {file_name}")

except Exception as e:
    print(f"An error occurred: {e}")
