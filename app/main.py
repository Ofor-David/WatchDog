from fastapi import FastAPI

app = FastAPI()

@app.get("/api")
def root():
    return {"Hello from Project Watchdog!"}