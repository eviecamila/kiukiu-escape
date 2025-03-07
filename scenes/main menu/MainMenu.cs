using Godot;
using System;

public partial class MainMenu : Node2D
{
	public override void _Process(double delta)
	{
		if (Input.IsActionJustPressed("ui_cancel"))
		{
			ShowQuestion();
		}
	}
	void changeScene(String path){
		var scene = ResourceLoader.Load<PackedScene>($"res://{path}.tscn").Instantiate();
		GetTree().Root.AddChild(scene);
	}
	void _on_start_pressed(){
	changeScene("scenes/menu");
	}
	void _on_settings_pressed(){
	changeScene("scenes/menu");
	}
	void _on_exit_pressed(){
	GetTree().Quit();
	}

	private void ShowQuestion()
	{
		var questionScene = GD.Load<PackedScene>("res://scenes/Question.tscn");
		var question = questionScene.Instantiate<Question>();
		
		question.QuestionText = "¿Quieres salir del juego?";
		question.YesText = "Sí, salir";
		question.NoText = "Cancelar";
		question.YesValue = true;
		question.NoValue = false;

		question.Connect("OptionSelected", new Callable(this, nameof(OnOptionSelected)));
		AddChild(question);
	}

	private void OnOptionSelected(bool selected)
	{
		if (selected)
		{
			GetTree().Quit();
		}
	}
}
