# Gym Timer
<img src="https://github.com/ClementJu/gym_timer/blob/master/figs/logo.png" width="100">

Flutter app - Gym timer and stopwatch with vocal indications, alarm and set counter

Thanks to Gym Timer, you can train without looking at your timer every 10 seconds. Vocal indications (which can be deactivated) tell you how much time is left before your next set. At the end, an alarm indicates you that the time is up. Both are hearable on top of your music. Also, a stopwatch (which can run in parallel) is available. Your screen does not lock automatically as long as the timer or the stopwatch is running.

The app is composed of three screens: Settings, Timer, Stopwatch.

## Timer

### Timer is not running
One tap on the time increases the counter by the amount of time defined in the settings (step). The time is bound by the interval defined in the settings (range).

A long press on the time allows you to define the duration you want. If you leave the minutes or seconds empty, it is automatically replaced with "0".

A double tap on the set counter undoes the last action and reverts the list to the previous one. You can then redo your last action if necessary.

The buttons allow to start the timer or reset everything (which clears the set list).

<img src="https://github.com/ClementJu/gym_timer/blob/master/figs/timer.png" width="200">



### Timer is running
Only the reset button works.

## Stopwatch

### Stopwatch is not running
A double tap on the set counter undoes the last action and reverts the list to the previous one. You can then redo your last action if necessary.

The buttons allow to start the stopwatch or reset everything (clear the set list).

### Stopwatch is running
The buttons allow to stop the timer or reset everything (clear the set list).

<img src="https://github.com/ClementJu/gym_timer/blob/master/figs/stopwatch.png" width="200">

## Settings
Define your own preferences.

You can activate or deactivate vocal indications according to your preferences.

The unilateral mode is to be used when you perform single-arm/leg exercises and rest between each side. The voice tells you which side is next (5 seconds before the end of the rest period).

The "Tap to increase" settings determines how the timer duration increases when taping the timer duration. The range defines the interval and the step the time increment induced by a tap. 

<img src="https://github.com/ClementJu/gym_timer/blob/master/figs/settings.png" width="200">
