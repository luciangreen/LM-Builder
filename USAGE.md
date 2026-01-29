# Installation and Usage Guide

## Quick Start

1. **Start the server:**
   ```bash
   ./start_server.sh
   ```
   
   Or manually:
   ```bash
   swipl
   ?- ['server.pl'].
   ?- start_server(8080).
   ```

2. **Access the application:**
   Open your web browser and go to: `http://localhost:8080`

## Features Overview

### Public Features (No Login Required)

1. **View Issues** (`/issues`)
   - Browse all issues in the system
   - Click on an issue to see its full content
   - Issues are stored as Markdown files and rendered to HTML

2. **Chat Interface** (`/chat`)
   - Ask questions like "what about issue example_issue"
   - Get automated summaries of issues
   - Natural language interaction

3. **View Articles** (`/articles`)
   - Browse all articles
   - Articles stored as Markdown files

4. **View Advocates** (`/advocates`)
   - See advocate profiles
   - Bio and professional information

5. **View Actions** (`/actions`)
   - Track action items
   - See status and assignments

6. **View Profiles** (`/profile`)
   - User profiles with bio
   - Contact details hidden for non-admin users

### Admin Features (Login Required)

**Default Admin Password:** `admin`

1. **Online File Editing** (`/edit_file`)
   - Browse and edit any file in the system
   - Direct editing of Markdown files
   - Save changes instantly

2. **VPS Backup** (`/backup`)
   - Create complete system backups
   - Requires admin password confirmation
   - Backups stored as tar.gz files in `/backups`

3. **Full Access**
   - View private contact details
   - All administrative functions

## File Structure

```
/issues/
  /example_issue/
    example_issue_main.md       # Main issue file
    additional_info.txt         # Additional files
    
/articles/
  sample_article.md             # Article files
  
/advocates/
  john_doe.md                   # Advocate profiles
  
/actions/
  followup_example.md           # Action items
  
/profiles/
  admin.md                      # User profiles
  
/databases/
  keywords.pl                   # Keyword mappings
  issues.pl                     # Issue metadata
  advocates.pl                  # Advocate data
  actions.pl                    # Action tracking
  
/static/
  style.css                     # Stylesheets
  
/backups/
  backup_*.tar.gz               # System backups
```

## Adding New Content

### Add a New Issue

1. Create directory: `mkdir issues/new_issue`
2. Create main file: `issues/new_issue/new_issue_main.md`
3. Add metadata to `databases/issues.pl`:
   ```prolog
   issue('new_issue', 'New Issue Title', 'active', 'high').
   ```

### Add a New Article

1. Create file: `articles/my_article.md`
2. Write content in Markdown format

### Add a New Advocate

1. Create file: `advocates/jane_smith.md`
2. Include bio, photo reference, and contact details
3. Add to database: `databases/advocates.pl`:
   ```prolog
   advocate('jane_smith', 'Jane Smith', 'jane@example.com', '+1-555-0124').
   ```

### Add a New Action

1. Create file: `actions/new_action.md`
2. Add to database: `databases/actions.pl`:
   ```prolog
   action('new_action', 'Description', 'pending', 'assignee', 'priority').
   ```

## Chat Commands

The chat interface understands natural language queries about issues:

- "what about issue example_issue" - Get summary of example_issue
- "what about issue new_issue" - Get summary of any issue

## Security Notes

1. **Change Default Password:**
   Edit `server.pl` and modify password checks in:
   - `handle_login/1` 
   - `run_backup_handler/1`

2. **Admin-Only Features:**
   - File editing
   - Backups
   - Private contact information viewing

3. **Session Management:**
   - Uses HTTP sessions for authentication
   - Logout available at `/logout`

## Backup and Restore

### Creating a Backup

1. Login as admin
2. Navigate to `/backup`
3. Enter admin password
4. Backup is created in `/backups` directory

### Restoring from Backup

```bash
tar -xzf backups/backup_TIMESTAMP.tar.gz
```

## Troubleshooting

### Server won't start
- Ensure SWI-Prolog is installed: `swipl --version`
- Check port 8080 is available: `netstat -tuln | grep 8080`

### Issues not showing
- Check directory exists: `ls issues/`
- Verify issue follows naming convention: `<name>/<name>_main.md`

### Chat not working
- Ensure issue exists in `issues/` directory
- Check issue has `_main.md` file

### Admin features not accessible
- Verify you're logged in: Navigate to `/login`
- Enter password: `admin` (or your custom password)
- Check session is active

## API Reference

All pages use simple GET/POST requests:

- `GET /` - Home page
- `GET /issues` - List issues
- `GET /issue?name=ISSUE_NAME` - View specific issue
- `GET /chat` - Chat interface
- `POST /chat_query` - Submit chat query (param: query)
- `GET /articles` - List articles
- `GET /advocates` - List advocates
- `GET /actions` - List actions
- `GET /profile` - View profiles
- `GET /login` - Login page
- `POST /login` - Submit login (param: password)
- `GET /logout` - Logout
- `GET /edit_file?file=PATH` - Edit file (admin)
- `POST /save_file` - Save file (admin, params: file, content)
- `GET /backup` - Backup page (admin)
- `POST /run_backup` - Execute backup (admin, param: password)

## Development

### Running Tests

```bash
./test_server.sh
```

This checks:
- SWI-Prolog installation
- Directory structure
- Database files
- Example content
- Prolog syntax

### Extending the System

The system is modular and can be extended by:

1. Adding new HTTP handlers
2. Creating new database files
3. Adding new page templates
4. Extending the chat query processor

See `server.pl` for implementation details.
