# Fixmate - Industrial Error Troubleshooting System

A comprehensive full-stack web application for industrial machine error troubleshooting, built with React, FastAPI, and Supabase.

## Features

- **Machine-specific error submission** with text input and photo capture
- **Multi-page frontend** with dedicated solution detail pages
- **Admin manual upload** with automatic parsing and database population
- **Advanced search and filtering** by machine type
- **Step-by-step resolution display** with manual references
- **Full authentication system** with Supabase integration
- **OCR processing** for uploaded error images
- **Responsive design** optimized for industrial environments

## Tech Stack

### Frontend
- React 18 with TypeScript
- Tailwind CSS for styling
- React Router for navigation
- Axios for API calls
- Lucide React for icons

### Backend
- FastAPI (Python)
- Supabase for database and authentication
- Pydantic for data validation
- Uvicorn for ASGI server

### Database
- PostgreSQL (via Supabase)
- Row Level Security (RLS) enabled
- Automated migrations

## Getting Started

### Prerequisites
- Node.js 18+
- Python 3.8+
- Supabase account

### Setup

1. **Clone and install frontend dependencies:**
   ```bash
   npm install
   ```

2. **Set up Supabase:**
   - Create a new Supabase project
   - Run the database migration from `supabase/migrations/create_tables.sql`
   - Get your project URL and anon key

3. **Configure environment variables:**
   - Update `.env` with your Supabase credentials
   - Update `backend/.env` with your Supabase credentials

4. **Install and run backend:**
   ```bash
   cd backend
   pip install -r requirements.txt
   python main.py
   ```

5. **Start the frontend:**
   ```bash
   npm run dev
   ```

## Application Flow

1. **Authentication** - Users sign up/login via Supabase Auth
2. **Error Submission** - Users select machine and describe error (text or photo)
3. **Solution Search** - System searches machine-specific solutions in database
4. **Results Display** - Shows matching solutions with preview
5. **Solution Detail** - Full step-by-step resolution instructions
6. **Admin Upload** - Upload manuals to extract and populate new solutions

## API Endpoints

- `POST /signup` - Create user account
- `POST /login` - Authenticate user
- `GET /machines` - List available machines
- `POST /errors` - Submit text error
- `POST /errors/image` - Submit error with image
- `GET /solutions` - Search solutions by machine/query
- `GET /solution/{id}` - Get detailed solution
- `POST /admin/upload-manual` - Upload and parse manual

## Database Schema

- **machines** - Available industrial machines
- **errors** - User-submitted error reports
- **solutions** - Parsed solutions from manuals
- **users** - User authentication (handled by Supabase Auth)

## Security Features

- Row Level Security (RLS) on all tables
- JWT-based authentication via Supabase
- Protected API endpoints
- Secure file upload handling

## Development

The application uses a modular architecture with:
- Separate services for different business logic
- Type-safe API with Pydantic models
- Responsive design with Tailwind CSS
- Clean component organization

## Production Considerations

- Implement real OCR service for image processing
- Add actual PDF/DOCX parsing for manual uploads
- Set up proper file storage and CDN
- Configure production database
- Add monitoring and logging
- Implement rate limiting