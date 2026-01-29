# LM-Builder
Issue Examination CRM - Prolog Web Server

## Overview

This is a Prolog-based web server system for managing issues, articles, advocates, and actions with chat-based issue verification capabilities.

## Features

### Core Features
- **Prolog Web Server**: Built using SWI-Prolog HTTP libraries
- **Issue Management**: Issues stored as Markdown files in `<issue>/<issue>_main.md` structure
- **Markdown to HTML Rendering**: Automatic conversion of Markdown content to HTML
- **Chat-based Issue Verification**: Ask "what about issue X" to get issue summaries
- **Articles, Advocates, and Actions**: All stored as Markdown files
- **User Profiles**: Bio and photo support with admin-only contact details
- **File-based Databases**: Keyword mapping for issues, advocates, and actions
- **Online File Editing**: Admin users can edit files through the web interface
- **Access Levels**: Public and Admin user levels
- **VPS Backups**: Automatic backup with admin password protection

### Directory Structure

```
/issues/               - Issue directories
  /example_issue/
    example_issue_main.md
/articles/             - Article Markdown files
/advocates/            - Advocate profile Markdown files
/actions/              - Action tracking Markdown files
/profiles/             - User profiles
/databases/            - File-based databases (Prolog files)
  keywords.pl
  issues.pl
  advocates.pl
  actions.pl
/static/               - Static files (CSS, images)
/backups/              - Backup archives
```

## Installation

### Prerequisites
- SWI-Prolog (version 8.0 or higher)
- Required Prolog libraries (installed with SWI-Prolog):
  - `library(http/thread_httpd)`
  - `library(http/http_dispatch)`
  - `library(http/http_parameters)`
  - `library(http/http_session)`
  - `library(http/html_write)`

### Setup

1. Clone the repository:
```bash
git clone https://github.com/luciangreen/LM-Builder.git
cd LM-Builder
```

2. Ensure all required directories exist (created automatically on first run)

3. Start the server:
```bash
swipl
['server.pl'].
start_server(8080).
```

The server will start on port 8080 by default.

## Usage

### Accessing the Server

Open a web browser and navigate to:
```
http://localhost:8080
```

### Features

#### 1. View Issues
- Navigate to `/issues` to see all available issues
- Click on an issue to view its content (Markdown rendered to HTML)

#### 2. Chat Interface
- Navigate to `/chat`
- Ask questions like "what about issue example_issue"
- Get automated responses with issue summaries

#### 3. Articles, Advocates, and Actions
- Browse articles at `/articles`
- View advocate profiles at `/advocates`
- See action items at `/actions`

#### 4. User Profiles
- View profiles at `/profile`
- Contact details are only visible to admin users

#### 5. Admin Login
- Navigate to `/login`
- Default password: `admin`
- Admin users can:
  - Edit files online
  - Access private contact details
  - Run VPS backups

#### 6. Online File Editing
- Login as admin
- Navigate to `/edit_file`
- Enter file path (e.g., `articles/sample_article.md`)
- Edit and save files directly

#### 7. VPS Backups
- Login as admin
- Navigate to `/backup`
- Enter admin password to confirm
- Creates tar.gz backup of all data directories

## Security

### User Access Levels

1. **Public Users**:
   - View issues, articles, advocates, actions
   - Use chat interface
   - View public profile information

2. **Admin Users**:
   - All public user capabilities
   - Edit files online
   - View private contact details
   - Run VPS backups
   - Full system access

### Password Protection
- Admin login required for sensitive operations
- Backup operations require re-authentication
- Session-based authentication

**Default Admin Password**: `admin` (should be changed in production)

## File-based Databases

The system uses Prolog files as databases:

### Keywords Database (`databases/keywords.pl`)
Maps keywords to issues, advocates, and actions:
```prolog
keyword('issue', issue, 'example_issue').
keyword('advocate', advocate, 'john_doe').
```

### Issues Database (`databases/issues.pl`)
Stores issue metadata:
```prolog
issue('example_issue', 'Example Issue', 'active', 'medium').
```

### Advocates Database (`databases/advocates.pl`)
Stores advocate information:
```prolog
advocate('john_doe', 'John Doe', 'john.doe@example.com', '+1-555-0123').
```

### Actions Database (`databases/actions.pl`)
Tracks actions and tasks:
```prolog
action('followup_example', 'Follow-up on Example Issue', 'pending', 'john_doe', 'high').
```

## API Endpoints

- `GET /` - Home page
- `GET /issues` - List all issues
- `GET /issue?name=<issue_name>` - View specific issue
- `GET /chat` - Chat interface
- `POST /chat_query` - Submit chat query
- `GET /articles` - List articles
- `GET /advocates` - List advocates
- `GET /actions` - List actions
- `GET /profile` - View profiles
- `GET /login` - Login page
- `POST /login` - Process login
- `GET /logout` - Logout
- `GET /edit_file` - File editor (admin only)
- `POST /save_file` - Save edited file (admin only)
- `GET /backup` - Backup page (admin only)
- `POST /run_backup` - Execute backup (admin only)

## Development

### Adding New Issues

1. Create a directory in `issues/`:
```bash
mkdir issues/new_issue
```

2. Create the main Markdown file:
```bash
echo "# New Issue\n\nIssue content here." > issues/new_issue/new_issue_main.md
```

3. Add to issues database:
```prolog
% In databases/issues.pl
issue('new_issue', 'New Issue', 'active', 'high').
```

### Adding New Advocates

1. Create a Markdown file in `advocates/`:
```bash
echo "# Jane Smith\n\n## Bio\n\nExperienced advocate..." > advocates/jane_smith.md
```

2. Add to advocates database:
```prolog
% In databases/advocates.pl
advocate('jane_smith', 'Jane Smith', 'jane@example.com', '+1-555-0124').
```

## Customization

### Changing the Port

Edit `server.pl` and modify the initialization line:
```prolog
:- initialization(start_server(8080), main).
```

Change `8080` to your desired port number.

### Changing Admin Password

Edit `server.pl` and modify the password check in `handle_login/1` and `run_backup_handler/1`:
```prolog
(Password = 'your_new_password' ->
```

## Troubleshooting

### Server won't start
- Ensure SWI-Prolog is installed
- Check that port 8080 is not in use
- Verify all required libraries are available

### Files not found
- Ensure directory structure exists
- Check file paths are correct
- Verify file permissions

### Chat not working
- Check issue exists in `issues/` directory
- Verify issue naming follows `<issue>/<issue>_main.md` pattern
- Ensure Markdown files are readable

## License

See LICENSE file for details.

## Contributing

Issues and pull requests are welcome!

## Author

luciangreen
