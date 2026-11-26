from django.http import Http404
from django.shortcuts import render

# The playlists shown on the home page.
my_playlists = [
    {"id": 1, "name": "Car Playlist", "numberOfSongs": 4},
    {"id": 2, "name": "Coding Playlist", "numberOfSongs": 2},
]

# Every song in the library. playlist_id links a song to its playlist.
my_songs = [
    {
        "id": 1,
        "Track": "thank u, next",
        "Artist": "Ariana Grande",
        "Album": "thank u, next",
        "Length": "3:27",
        "playlist_id": 1,
    },
    {
        "id": 2,
        "Track": "One Kiss",
        "Artist": "Dua Lipa, Calvin Harris",
        "Album": "One Kiss",
        "Length": "3:34",
        "playlist_id": 1,
    },
    {
        "id": 3,
        "Track": "Better Now",
        "Artist": "Post Malone",
        "Album": "beerbongs & bentleys",
        "Length": "3:51",
        "playlist_id": 1,
    },
    {
        "id": 4,
        "Track": "Shape of You",
        "Artist": "Ed Sheeran",
        "Album": "Divide",
        "Length": "3:53",
        "playlist_id": 1,
    },
    {
        "id": 5,
        "Track": "Blinding Lights",
        "Artist": "The Weeknd",
        "Album": "After Hours",
        "Length": "3:20",
        "playlist_id": 2,
    },
    {
        "id": 6,
        "Track": "Levitating",
        "Artist": "Dua Lipa",
        "Album": "Future Nostalgia",
        "Length": "3:23",
        "playlist_id": 2,
    },
]


def home(request):
    return render(request, "zing_it/home.html", {"my_playlists": my_playlists})


def playlist(request, id):
    songs = []
    for song in my_songs:
        if song["playlist_id"] == id:
            songs.append(song)

    if not songs:
        raise Http404("Playlist does not exist")

    playlist_name = ""
    for item in my_playlists:
        if item["id"] == id:
            playlist_name = item["name"]

    return render(
        request,
        "zing_it/songs.html",
        {"songs": songs, "playlist_name": playlist_name},
    )


def about(request):
    return render(request, "zing_it/about.html")
