from django.test import SimpleTestCase
from django.urls import reverse

from zing_it.views import my_playlists, my_songs


class HomePageTests(SimpleTestCase):
    def test_home_lists_every_playlist(self):
        response = self.client.get(reverse("home"))
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, "zing_it/home.html")
        self.assertTemplateUsed(response, "zing_it/base.html")
        for playlist in my_playlists:
            self.assertContains(response, playlist["name"])
            self.assertContains(response, f'{playlist["numberOfSongs"]} songs')
            self.assertContains(
                response, reverse("playlist", args=[playlist["id"]])
            )

    def test_home_uses_static_cover(self):
        response = self.client.get(reverse("home"))
        self.assertContains(response, "zing_it/images/music")


class PlaylistPageTests(SimpleTestCase):
    def test_playlist_shows_only_its_songs(self):
        response = self.client.get(reverse("playlist", args=[1]))
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, "zing_it/songs.html")
        self.assertEqual(response.context["playlist_name"], "Car Playlist")
        expected = [s for s in my_songs if s["playlist_id"] == 1]
        self.assertEqual(response.context["songs"], expected)
        self.assertContains(response, f"{len(expected)} songs")
        self.assertContains(response, "<title>Car Playlist | Zing It</title>", html=True)

    def test_second_playlist(self):
        response = self.client.get("/playlist/2/")
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Coding Playlist")

    def test_missing_playlist_returns_404(self):
        response = self.client.get("/playlist/5/")
        self.assertEqual(response.status_code, 404)

    def test_non_integer_id_does_not_match(self):
        response = self.client.get("/playlist/abc/")
        self.assertEqual(response.status_code, 404)


class AboutPageTests(SimpleTestCase):
    def test_about_page(self):
        response = self.client.get(reverse("about"))
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, "zing_it/about.html")
        self.assertContains(response, "Soundtrack your life")
