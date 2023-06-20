# Calendar Event Generator

This Python script generates an `.ics` file with a predefined set of events that can be imported into most calendar applications such as Google Calendar, Outlook, and Apple Calendar.

## Requirements

- Python 3.6 or higher

## Setup

1. Clone this repository or download the source files.

2. Navigate to the directory containing the files.

3. Install the required Python packages by running the following command:

    ```sh
    pip install -r requirements.txt
    ```

## Usage

1. Modify the `create_ics_file.py` script to include your events. The script contains a list named `events`, where each event is a dictionary with the keys `summary`, `start`, `end`, and `description`. For example:

    ```python
    events = [
        {
            "summary": "Event Name",
            "start": datetime(2023, 6, 20, 10, 30),
            "end": datetime(2023, 6, 20, 11, 30),
            "description": "Description of the event"
        },
        # ... additional events
    ]
    ```

2. Run the script by executing the following command in your terminal or command prompt:

    ```sh
    python create_ics_file.py
    ```

3. The script will generate a file named `schedule.ics` in the current directory.

4. Import the `schedule.ics` file into your preferred calendar application.

## Customization

You can customize the events by modifying the `events` list in the `create_ics_file.py` script. Each event should be a dictionary with the following keys:

- `summary`: The name of the event.
- `start`: The start time of the event as a `datetime` object.
- `end`: The end time of the event as a `datetime` object.
- `description`: A description of the event (optional).

## License

This project is licensed under the terms of the MIT license.

## Creation

[🤖](https://chat.openai.com/share/e7bf0274-80d4-4f83-9e86-4abdef859bb9)
