---
description: Extract screenshots
---

# Process Video

Extracts unique screenshots and transcribes audio from a video file

## Usage

```
/process-video <video_path> [threshold]
```

**Arguments:**
- `video_path` - Path to video file (.mp4, .mov, .mkv, .webm)
- `threshold` - Scene detection sensitivity (default: 0.3)

## What This Does

 **Extract Screenshots** - Uses FFmpeg scene detection to capture unique frames

## Execution

Run both processing steps:

```bash
# Extract screenshots
python3 ~/Documents/demos/extract_screenshots.py "$VIDEO_PATH" "$THRESHOLD"

```

## Threshold Quick Reference

| Value | Result | Use Case |
|-------|--------|----------|
| 0.5–0.7 | 5–15 frames | Major changes only |
| 0.3 | 20–40 frames | **Default, balanced** |
| 0.1 | 40–60 frames | Detailed coverage |
| 0.03 | 60–80+ frames | Maximum detail |

## Output

**Screenshots:** `screenshots_<video_name>/` in same directory as video
- `img_1.jpg`, `img_2.jpg`, etc.


## Examples

```bash
# Default processing
/process-video ~/Downloads/meeting.mp4

# More frames (lower threshold)
/process-video ~/Downloads/presentation.mov 0.1

# Maximum detail
/process-video ~/Documents/demo.mp4 0.03
```

## Requirements

- **FFmpeg:** `brew install ffmpeg`

## Partial Processing

**Screenshots only:**
```bash
python3 ~/Documents/demos/extract_screenshots.py <video_path> [threshold]
```


## Related

- Use `video-processor` agent for interactive help: `/agent video-processor`
