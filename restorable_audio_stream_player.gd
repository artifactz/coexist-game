extends AudioStreamPlayer
class_name RestorableAudioStreamPlayer
## Workaround for an issue with audio playback in web build where a sound becomes
## quieter every time it is played.

var original_stream: AudioStream

func _ready():
	# Keep copy of stream object and restore it after every finished play
	original_stream = stream.duplicate()
	finished.connect(_restore)

## Manual restore function to be called once between bulk plays to avoid too much copying.
## Also disables auto-restore.
func restore():
	# Apparently, disconnect does NOT throw an error if already disconnected
	finished.disconnect(_restore)
	_restore()

func _restore():
	stream = original_stream.duplicate()
