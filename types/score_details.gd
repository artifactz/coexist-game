class_name ScoreDetails

var score: int
var streak_bonus: int
var speed_bonus: int

func _init(difficulty_factor: float, correct_streak: int, speed_bonus: float) -> void:
	self.streak_bonus = round(difficulty_factor * (correct_streak - 1) * 10.0)
	self.speed_bonus = round(difficulty_factor * speed_bonus * 10.0)
	self.score = round(difficulty_factor * 10.0) + self.streak_bonus + self.speed_bonus
