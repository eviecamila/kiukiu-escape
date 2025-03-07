using Godot;
using System;

public partial class player : CharacterBody2D
{
	private float speed = 400f;
	private AnimatedSprite2D _animatedSprite;

	public override void _Ready()
	{
		_animatedSprite = GetNode<AnimatedSprite2D>("AnimatedSprite2D");
	}

	public override void _Process(double delta)
	{
		Vector2 movement = Vector2.Zero;

		// Verificar acciones de movimiento
		if (Input.IsActionPressed("ui_left")) movement.X -= 1;
		if (Input.IsActionPressed("ui_right")) movement.X += 1;
		if (Input.IsActionPressed("ui_up")) movement.Y -= 1;
		if (Input.IsActionPressed("ui_down")) movement.Y += 1;

		// Normalizar vector de movimiento
		if (movement.Length() > 0)
		{
			movement = movement.Normalized();
			_animatedSprite.Play("walk"); // Asegúrate de que la animación "walk" existe
		}
		else
		{
			_animatedSprite.Stop();
		}
		// Mover el personaje
		Position += movement * speed * (float)delta;

		// Girar sprite horizontalmente
		if (movement.X != 0)
		{
			_animatedSprite.FlipH = movement.X < 0;
		}
	}
}
