from datetime import datetime
import pytz

events = [
    {
        "summary": "Start building the foundation of your portfolio website",
        "start": datetime(2023, 6, 20, 10, 30),
        "end": datetime(2023, 6, 20, 11, 30),
        "description": "Since this is a long-term project, an hour of focused work can help you make progress."
    },
    {
        "summary": "Take a break and walk your dog",
        "start": datetime(2023, 6, 20, 11, 30),
        "end": datetime(2023, 6, 20, 12, 0),
        "description": "This might also be a good time to avoid the rain and the peak heat before the calls start."
    },
    {
        "summary": "Apply for jobs and reach out to DeepGram employees on LinkedIn",
        "start": datetime(2023, 6, 20, 12, 0),
        "end": datetime(2023, 6, 20, 13, 0),
        "description": ""
    },
    {
        "summary": "Attend your scheduled calls",
        "start": datetime(2023, 6, 20, 13, 0),
        "end": datetime(2023, 6, 20, 16, 0),
        "description": ""
    },
    {
        "summary": "Continue applying for jobs",
        "start": datetime(2023, 6, 20, 16, 0),
        "end": datetime(2023, 6, 20, 17, 30),
        "description": "Spend this time shooting out applications and customizing cover letters."
    },
    {
        "summary": "Resume working on your portfolio website",
        "start": datetime(2023, 6, 20, 17, 30),
        "end": datetime(2023, 6, 20, 18, 30),
        "description": "Plan out the features you want to add, such as GraphQL integration and resume parsing."
    },
    {
        "summary": "Wind down and prepare for your wife’s arrival",
        "start": datetime(2023, 6, 20, 18, 30),
        "end": datetime(2023, 6, 20, 19, 30),
        "description": "Perhaps make dinner or tidy up the house."
    },
    {
        "summary": "Spend quality time with your wife",
        "start": datetime(2023, 6, 20, 19, 30),
        "end": datetime(2023, 6, 20, 23, 59),
        "description": ""
    }
]

# Calendar content
content = [
    "BEGIN:VCALENDAR",
    "VERSION:2.0",
    "PRODID:-//ChatGPT//EN",
]

# Add events to the content
for event_data in events:
    content.append("BEGIN:VEVENT")
    content.append(f"SUMMARY:{event_data['summary']}")
    content.append(
        f"DTSTART;TZID=US/Eastern:{event_data['start'].strftime('%Y%m%dT%H%M%S')}")
    content.append(
        f"DTEND;TZID=US/Eastern:{event_data['end'].strftime('%Y%m%dT%H%M%S')}")
    content.append(f"DESCRIPTION:{event_data['description']}")
    content.append("END:VEVENT")

# End of calendar content
content.append("END:VCALENDAR")

# Joining content and saving to .ics file
ics_content = "\r\n".join(content)
ics_file_path = 'schedule.ics'
with open(ics_file_path, 'w') as f:
    f.write(ics_content)

print(f".ics file created at {ics_file_path}")
