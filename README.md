# Scele Notifier
Scrap latest academic announcements and courses activity from Student Center E-Learning Environment (SCeLE) in Fasilkom UI (Faculty of Computer Science, University of Indonesia) https://scele.cs.ui.ac.id.

## Installation Guide
#### 1. Install dependencies
Required Perl Modules:
- Mojo::DOM
- WWW::Mechanize

#### 2. Configuration
Make a copy of `.env` from `.env.example`. Then edit each entry of .env:
- `USERNAME` and `PASSWORD` denotes the user credentials.
- `EMAIL_TO` and `EMAIL_FROM` denotes the receiver's and the sender's email address .
- `COURSES` denotes the list of course ID separated by commas.

#### 3. Set up a cron job to run the script periodically.