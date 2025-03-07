using Godot;
using System;

public partial class Question : Control
{
	[Signal]
	public delegate void OptionSelectedEventHandler(bool selectedValue);

	[Export] public string QuestionText { get; set; } = "Pregunta";
	[Export] public string YesText { get; set; } = "Sí";
	[Export] public string NoText { get; set; } = "No";
	[Export] public bool YesValue { get; set; } = true;
	[Export] public bool NoValue { get; set; } = false;

	private Button yesButton;
	private Button noButton;
	private RichTextLabel questionLabel;

	public override void _Ready()
	{
		yesButton = GetNode<Button>("MarginContainer/VBoxContainer/ButtonContainer/YesButton");
		noButton = GetNode<Button>("MarginContainer/VBoxContainer/ButtonContainer/NoButton");
		questionLabel = GetNode<RichTextLabel>("MarginContainer/VBoxContainer/HBoxContainer/QuestionLabel");

		UpdateUI();
		yesButton.GrabFocus();
	}

	private void UpdateUI()
	{
		questionLabel.Text = $"[center][b]{QuestionText}[/b]";
		yesButton.Text = YesText;
		noButton.Text = NoText;
	}

	public override void _Input(InputEvent @event)
	{
		if (@event is InputEventKey eventKey && eventKey.Pressed)
		{
			if (eventKey.Keycode == Key.Left || eventKey.Keycode == Key.Right)
			{
				SwapFocus();
			}
			else if (eventKey.Keycode == Key.Enter || eventKey.Keycode == Key.Space)
			{
				OnButtonPressed();
			}
		}
	}

	private void SwapFocus()
	{
		if (yesButton.HasFocus())
		{
			noButton.GrabFocus();
		}
		else
		{
			yesButton.GrabFocus();
		}
	}

	private void OnButtonPressed()
	{
		bool result = yesButton.HasFocus() ? YesValue : NoValue;
		EmitSignal(nameof(OptionSelected), result);
		QueueFree();
	}

	// Conexión automática de botones (opcional)
	private void _on_YesButton_pressed() => OnButtonPressed();
	private void _on_NoButton_pressed() => OnButtonPressed();
}
