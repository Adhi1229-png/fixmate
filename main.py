from fastapi import FastAPI, HTTPException, Depends, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import uvicorn
from typing import Optional, List
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

from models import *
from database import supabase
from services.auth_service import verify_token, create_user, login_user
from services.error_service import submit_error, submit_error_with_image, search_solutions
from services.solution_service import get_solution_by_id
from services.manual_service import upload_and_parse_manual

app = FastAPI(title="Fixmate API", description="Industrial Error Troubleshooting API", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

security = HTTPBearer()

@app.get("/")
async def root():
    return {"message": "Fixmate API is running"}

# Auth endpoints
@app.post("/signup", response_model=AuthResponse)
async def signup(user: UserCreate):
    try:
        result = create_user(user.email, user.password)
        return result
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/login", response_model=AuthResponse)
async def login(user: UserLogin):
    try:
        result = login_user(user.email, user.password)
        return result
    except Exception as e:
        raise HTTPException(status_code=401, detail=str(e))

# Machine endpoints
@app.get("/machines", response_model=List[Machine])
async def get_machines():
    try:
        response = supabase.table("machines").select("*").order("machine_name").execute()
        return response.data
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Error submission endpoints
@app.post("/errors", response_model=ErrorResponse)
async def submit_text_error(
    error: ErrorSubmission,
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    try:
        user = verify_token(credentials.credentials)
        result = submit_error(error, user['id'])
        return result
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/errors/image", response_model=ErrorResponse)
async def submit_image_error(
    machine_id: str = Form(...),
    error_code: Optional[str] = Form(None),
    image: UploadFile = File(...),
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    try:
        user = verify_token(credentials.credentials)
        result = await submit_error_with_image(machine_id, error_code, image, user['id'])
        return result
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# Solution endpoints
@app.get("/solutions", response_model=List[SolutionSummary])
async def get_solutions(machine_id: str, query: Optional[str] = None):
    try:
        solutions = search_solutions(machine_id, query)
        return solutions
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/solution/{solution_id}", response_model=SolutionDetail)
async def get_solution(solution_id: str):
    try:
        solution = get_solution_by_id(solution_id)
        return solution
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))

# Admin endpoints
@app.post("/admin/upload-manual")
async def upload_manual(
    machine_id: str = Form(...),
    manual_file: UploadFile = File(...),
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    try:
        user = verify_token(credentials.credentials)
        result = await upload_and_parse_manual(machine_id, manual_file)
        return result
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)