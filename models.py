from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

# Auth Models
class UserCreate(BaseModel):
    email: EmailStr
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class AuthResponse(BaseModel):
    user: dict
    session: dict
    message: str

# Machine Models
class Machine(BaseModel):
    id: str
    machine_name: str
    description: Optional[str] = None
    created_at: datetime

# Error Models
class ErrorSubmission(BaseModel):
    machine_id: str
    error_code: Optional[str] = None
    error_text: Optional[str] = None

class ErrorResponse(BaseModel):
    id: str
    message: str
    solutions_found: int

# Solution Models
class SolutionSummary(BaseModel):
    id: str
    error_code: str
    description: str
    topic: str
    machine_name: str

class SolutionDetail(BaseModel):
    id: str
    error_code: str
    description: str
    resolution_steps: str
    topic: str
    page_number: int
    machine_name: str
    created_at: datetime

# Admin Models
class ManualUploadResponse(BaseModel):
    message: str
    solutions_parsed: int