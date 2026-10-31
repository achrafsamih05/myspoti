import urllib.request

urls = [
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3'
]

print("Probing sample audio URLs...")
for url in urls:
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Myspoti-QA/1.0'})
        with urllib.request.urlopen(req, timeout=10) as resp:
            content_type = resp.headers.get("Content-Type")
            content_length = resp.headers.get("Content-Length")
            print(f"[SUCCESS] {url} -> HTTP {resp.status}, Content-Type: {content_type}, Size: {content_length} bytes")
    except Exception as e:
        print(f"[FAILURE] {url} -> {e}")

