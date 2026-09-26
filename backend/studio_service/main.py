import io
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import Response
from fastapi.middleware.cors import CORSMiddleware
from united import process_image

app = FastAPI(title="AI Virtual Studio - Module 1 (KalaSetu)")

# Enable CORS for Flutter web / emulator access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def health_check():
    return {"status": "ok", "service": "KalaSetu AI Virtual Studio", "version": "1.0.0"}


@app.post("/api/v1/studio-transform")
async def studio_transform(file: UploadFile = File(...)):
    """
    Receives raw handicraft photo, applies CLAHE contrast enhancement,
    edge-preserving bilateral denoising, U2-Net background removal,
    and studio drop-shadow rendering.
    """
    if file.content_type not in ["image/jpeg", "image/jpg", "image/png", "application/octet-stream"]:
        # Be forgiving of generic octet-stream MIME types from some HTTP clients
        pass

    try:
        raw_bytes = await file.read()
        if not raw_bytes:
            raise HTTPException(status_code=400, detail="Empty file submitted.")

        processed_bytes = process_image(raw_bytes)

        return Response(content=processed_bytes, media_type="image/jpeg")

    except ValueError as ve:
        raise HTTPException(status_code=400, detail=str(ve))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Studio processing error: {str(e)}")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
