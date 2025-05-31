extends Clip
class_name CompositeClip

@export var clips: Array[Clip] = []:
	set(v):
		clips = v
		emit_changed()

func find_next_clip_after(clip: Clip):
	var soonest_start = 9999999999999999
	var out: Clip = null
	for c in clips:
		if c != clip:
			if c.start > clip.start and c.start < soonest_start:
				soonest_start = c.start
				out = c
	return out

func render(percent: float):
	for clip in clips:
		if clip.start <= percent and clip.end > percent:
			return clip.render(percent)
