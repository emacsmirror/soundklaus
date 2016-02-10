;;; soundklaus-playlist.el --- SoundKlaus playlists -*- lexical-binding: t -*-

;; Copyright © 2014-2016 r0man <roman@burningswell.com>
;; Author: r0man <roman@burningswell.com>

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; SoundKlaus playlists

;;; Code:

(require 'emms)
(require 'dash)
(require 'soundklaus-request)
(require 'soundklaus-resource)
(require 'soundklaus-user)

(define-soundklaus-resource playlist "/playlists/:id"
  "A SoundCloud playlist"
  ((id "The id of the playlist")
   (user "The minimal representation of the playlist owner")
   (title "The title of the playlist")
   (tracks "The tracks of the  playlist")
   (duration "The duration of the playlist in milliseconds")))

(defun soundklaus-make-playlist (assoc-list)
  "Make a SoundCloud playlist instance from ASSOC-LIST."
  (let ((instance (soundklaus-slurp-instance 'soundklaus-playlist assoc-list)))
    (with-slots (user tracks) instance
      (setf user (soundklaus-make-user user))
      (setf tracks (mapcar 'soundklaus-make-track tracks))
      instance)))

(defun soundklaus-playlist-download-directory (playlist)
  "Return the download directory for PLAYLIST."
  (expand-file-name
   (concat (file-name-as-directory soundklaus-download-dir)
  	   (file-name-as-directory (soundklaus-safe-path (soundklaus-playlist-username playlist)))
  	   (soundklaus-safe-path (soundklaus-playlist-title playlist)))))

(defun soundklaus-playlist-track-download-filename (playlist track n)
  "Return the download filename of a song in the PLAYLIST.
TRACK is song number N."
  (expand-file-name
   (concat (file-name-as-directory (soundklaus-playlist-download-directory playlist))
	   (format "%02d-%s.mp3" n (soundklaus-safe-path (soundklaus-track-title track))))))

(defun soundklaus-playlist-time (playlist)
  "Return the PLAYLIST duration formatted as HH:MM:SS."
  (soundklaus-format-duration (soundklaus-playlist-duration playlist)))

(defun soundklaus-playlist-username (playlist)
  "Return the username of PLAYLIST."
  (soundklaus-user-username (soundklaus-playlist-user playlist)))

(defun soundklaus-playlist-path (playlist)
  "Return the relative URL of PLAYLIST."
  (-when-let (id (soundklaus-playlist-id playlist))
    (concat "/playlists/" (number-to-string id))))

(defun soundklaus-playlist-fetch (playlist)
  "Fetch the PLAYLIST from the SoundCloud API."
  (let* ((request (soundklaus-make-request (soundklaus-playlist-path playlist)))
         (response (soundklaus-send-sync-request request)))
    (soundklaus-make-playlist response)))

(define-emms-source soundklaus-playlist (playlist)
  "An EMMS source for a SoundCloud PLAYLIST."
  (mapc 'emms-insert-soundklaus-track
        (soundklaus-playlist-tracks playlist)))

(provide 'soundklaus-playlist)

;;; soundklaus-playlist.el ends here